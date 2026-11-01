package app.linksy.media

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Rect
import android.hardware.camera2.CameraCaptureSession
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraDevice
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraMetadata
import android.hardware.camera2.CaptureRequest
import android.hardware.camera2.params.MeteringRectangle
import android.media.MediaCodec
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import android.util.Range
import android.util.Size
import android.view.Surface
import app.linksy.Logs
import org.json.JSONObject
import kotlin.math.atan
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.tan

/// The phone as a webcam (docs/protocol.md §4.8, kind `camera`), with the controls of
/// a camera app: lenses (front, back, and every back camera the phone
/// exposes), zoom, torch, tap-to-focus and manual focus, exposure
/// compensation and locks, white balance, stabilization and stream quality.
///
/// Every change updates the running capture request: the stream never stops.
/// Controls come from the phone's screen ([set]) or from the computer
/// (`camera_control` messages on the session, see docs/android-app.md). [onState] hears
/// every change, for the phone's controls to follow.
@SuppressLint("MissingPermission") // Dart asks for the camera before a session starts.
class CameraShare(
    private val context: Context,
    private val session: String,
    private val onEnded: () -> Unit,
) : Share {
    private val thread = HandlerThread("linksy-camera").apply { start() }
    private val handler = Handler(thread.looper)
    private val manager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    private var encoder: H264Encoder
    /// The stream: 1280×720, or 1920×1080 when the computer asks and the
    /// camera has it (desktop 0.6.0).
    @Volatile var size: Size
        private set
    private var device: CameraDevice? = null
    private var capture: CameraCaptureSession? = null
    @Volatile private var stopped = false
    /// Turns and places the picture; the camera draws into it.
    private val renderer: GlRenderer
    /// Follows how the phone is held, for automatic rotation.
    private val orientation: android.view.OrientationEventListener
    private var held = 0

    /// What can be chosen: a lens per camera the phone exposes, by facing.
    private val lenses: List<Lens>
    private var lens: Lens
    private var chars: CameraCharacteristics

    // The controls, as the phone or the computer last set them.
    private var zoom = 1f
    private var torch = false
    private var focus = "auto" // auto (continuous), point (tapped, held), manual
    private var focusPoint: Pair<Float, Float>? = null
    private var focusDistance = 0f // 0..1 of the lens's range, manual only
    private var exposure = 0 // compensation steps
    private var exposureLock = false
    private var whiteBalance = "auto"
    private var whiteBalanceLock = false
    private var stabilization = true
    private var quality = "standard"
    private var fps = 30
    /// What the current camera delivers (its own size and shape).
    private var input = Size(1280, 720)
    /// The picture's shape: landscape (fills the frame) or portrait (bars at
    /// the sides). Either way it's kept upright for how the phone is held.
    private var orientationMode = "landscape"
    /// The last upright portrait rotation, kept while the phone is held
    /// sideways with portrait asked for.
    private var lastPortrait = -1

    /// Every change, as [state] JSON, on the camera thread.
    @Volatile var onState: ((JSONObject) -> Unit)? = null

    private val reader: Thread

    init {
        lenses = findLenses()
        lens = lenses.firstOrNull { it.facing == "back" && it.main } ?: lenses.first()
        chars = manager.getCameraCharacteristics(lens.id)
        // The stream is 1280×720 to start; each camera delivers its own
        // size, fitted into it without stretching.
        size = HD
        input = cameraSize(chars, fps, size)
        encoder = H264Encoder(size.width, size.height, bitrate = bitrate(quality), fps = fps, label = "Webcam", session = session, onEnded = onEnded)
        renderer = GlRenderer(input, encoder.inputSurface, encoder.width, encoder.height)
        orientation = object : android.view.OrientationEventListener(context) {
            override fun onOrientationChanged(degrees: Int) {
                if (degrees == ORIENTATION_UNKNOWN) return
                val snapped = ((degrees + 45) / 90 * 90) % 360
                if (snapped != held) handler.post {
                    held = snapped
                    turn()
                }
            }
        }
        if (orientation.canDetectOrientation()) orientation.enable()
        turn()
        open()
        reader = Thread(::readControls, "linksy-camera-control").apply { isDaemon = true; start() }
    }

    // Lenses.

    private class Lens(val id: String, val facing: String, val equivalent: Float, val main: Boolean)

    /// Each camera the phone lists, with its field of view as a zoom factor
    /// of the main camera of the same facing (0.6× ultra-wide, 3× tele…).
    private fun findLenses(): List<Lens> {
        val all = manager.cameraIdList.mapNotNull { id ->
            val c = manager.getCameraCharacteristics(id)
            val facing = when (c.get(CameraCharacteristics.LENS_FACING)) {
                CameraCharacteristics.LENS_FACING_BACK -> "back"
                CameraCharacteristics.LENS_FACING_FRONT -> "front"
                else -> return@mapNotNull null
            }
            val sizes = c.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
                ?.getOutputSizes(MediaCodec::class.java).orEmpty()
            if (sizes.isEmpty()) return@mapNotNull null
            Triple(id, facing, fov(c))
        }
        return all.groupBy { it.second }.flatMap { (facing, cams) ->
            // The first one Android lists for a facing is its main camera.
            val main = cams.first()
            cams.map { (id, _, fov) ->
                val ratio = if (fov > 0 && main.third > 0) (tan(main.third / 2) / tan(fov / 2)).toFloat() else 1f
                Lens(id, facing, (ratio * 10).roundToInt() / 10f, id == main.first)
            }
        }
    }

    /// Horizontal field of view in radians, from focal length and sensor width.
    private fun fov(c: CameraCharacteristics): Double {
        val focal = c.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)?.firstOrNull() ?: return 0.0
        val width = c.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE)?.width ?: return 0.0
        return 2 * atan(width / (2.0 * focal))
    }

    // The camera.

    private fun open() {
        manager.openCamera(lens.id, object : CameraDevice.StateCallback() {
            override fun onOpened(camera: CameraDevice) {
                if (stopped) return camera.close()
                device = camera
                configure()
            }

            // Closing it to switch reports a disconnect too: only the camera in use counts.
            override fun onDisconnected(camera: CameraDevice) {
                if (device != camera) return
                Logs.add("Webcam: Android took the camera away")
                onEnded()
            }

            override fun onError(camera: CameraDevice, error: Int) {
                if (device != camera && device != null) return
                Logs.add("Webcam: camera error $error")
                onEnded()
            }
        }, handler)
    }

    /// A capture session drawing into the renderer (which feeds the encoder
    /// and the phone's preview).
    private fun configure() {
        val camera = device ?: return
        runCatching { capture?.close() }
        capture = null
        // A size this camera really delivers for this frame rate: anything
        // else, Android rounds to another shape and the picture stretches.
        input = cameraSize(chars, fps, size)
        renderer.setCamera(input, chars.get(CameraCharacteristics.SENSOR_ORIENTATION) ?: 90)
        val outputs = listOf(renderer.input)
        @Suppress("DEPRECATION")
        camera.createCaptureSession(outputs, object : CameraCaptureSession.StateCallback() {
            override fun onConfigured(s: CameraCaptureSession) {
                if (stopped) return
                capture = s
                apply()
                encoder.keyframe()
            }

            override fun onConfigureFailed(s: CameraCaptureSession) {
                Logs.add("Webcam: the camera refused ${input.width}×${input.height}")
                onEnded()
            }
        }, handler)
    }

    /// The repeating request from the current controls.
    private fun request(trigger: Boolean = false): CaptureRequest? {
        val camera = device ?: return null
        return camera.createCaptureRequest(CameraDevice.TEMPLATE_RECORD).apply {
            addTarget(renderer.input)
            fpsRange(fps)?.let { set(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, it) }

            // Zoom: the ratio API (Android 11+, which also reaches the
            // ultra-wide on logical cameras), else a crop.
            val active = chars.get(CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE) ?: Rect(0, 0, size.width, size.height)
            if (Build.VERSION.SDK_INT >= 30 && zoomRange().lower != zoomRange().upper) {
                set(CaptureRequest.CONTROL_ZOOM_RATIO, zoom)
            } else if (zoom > 1f) {
                val w = (active.width() / zoom).toInt()
                val h = (active.height() / zoom).toInt()
                set(CaptureRequest.SCALER_CROP_REGION, Rect(active.centerX() - w / 2, active.centerY() - h / 2, active.centerX() + w / 2, active.centerY() + h / 2))
            }

            // Exposure: compensation, lock, metering point; the torch needs
            // plain auto-exposure.
            set(CaptureRequest.CONTROL_MODE, CameraMetadata.CONTROL_MODE_AUTO)
            set(CaptureRequest.CONTROL_AE_MODE, CameraMetadata.CONTROL_AE_MODE_ON)
            set(CaptureRequest.CONTROL_AE_EXPOSURE_COMPENSATION, exposure)
            set(CaptureRequest.CONTROL_AE_LOCK, exposureLock)
            set(CaptureRequest.FLASH_MODE, if (torch && hasFlash()) CameraMetadata.FLASH_MODE_TORCH else CameraMetadata.FLASH_MODE_OFF)

            // Focus.
            // The tapped point is on the stream; the camera meters its own picture.
            val regions = focusPoint?.let { renderer.toCamera(it.first, it.second) }?.let { arrayOf(metering(it, active)) }
            when {
                focus == "manual" && manualFocus() -> {
                    set(CaptureRequest.CONTROL_AF_MODE, CameraMetadata.CONTROL_AF_MODE_OFF)
                    val near = chars.get(CameraCharacteristics.LENS_INFO_MINIMUM_FOCUS_DISTANCE) ?: 0f
                    set(CaptureRequest.LENS_FOCUS_DISTANCE, focusDistance * near)
                }
                focus == "point" && regions != null && autoFocus() -> {
                    set(CaptureRequest.CONTROL_AF_MODE, CameraMetadata.CONTROL_AF_MODE_AUTO)
                    if (maxRegions(CameraCharacteristics.CONTROL_MAX_REGIONS_AF) > 0) set(CaptureRequest.CONTROL_AF_REGIONS, regions)
                    if (trigger) set(CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_START)
                }
                autoFocus() -> set(CaptureRequest.CONTROL_AF_MODE, CameraMetadata.CONTROL_AF_MODE_CONTINUOUS_VIDEO)
            }
            if (regions != null && maxRegions(CameraCharacteristics.CONTROL_MAX_REGIONS_AE) > 0) {
                set(CaptureRequest.CONTROL_AE_REGIONS, regions)
            }

            // White balance.
            set(CaptureRequest.CONTROL_AWB_MODE, awbMode(whiteBalance))
            set(CaptureRequest.CONTROL_AWB_LOCK, whiteBalanceLock)

            // Stabilization: electronic, and optical where the lens has it.
            if (videoStabilization()) {
                set(
                    CaptureRequest.CONTROL_VIDEO_STABILIZATION_MODE,
                    if (stabilization) CameraMetadata.CONTROL_VIDEO_STABILIZATION_MODE_ON else CameraMetadata.CONTROL_VIDEO_STABILIZATION_MODE_OFF,
                )
            }
            if (opticalStabilization()) {
                set(
                    CaptureRequest.LENS_OPTICAL_STABILIZATION_MODE,
                    if (stabilization) CameraMetadata.LENS_OPTICAL_STABILIZATION_MODE_ON else CameraMetadata.LENS_OPTICAL_STABILIZATION_MODE_OFF,
                )
            }
        }.build()
    }

    /// Puts the controls into effect (on the camera thread).
    private fun apply(trigger: Boolean = false) {
        val s = capture ?: return
        runCatching {
            if (trigger) request(trigger = true)?.let { s.capture(it, null, handler) }
            request()?.let { s.setRepeatingRequest(it, null, handler) }
        }.onFailure { Log.w("linksy", "camera controls not applied", it) }
        onState?.invoke(state())
    }

    /// The picture's rotation now: upright for how the phone is held (the
    /// camera's own formula for photo orientation), within the chosen shape.
    /// Landscape follows the phone: held sideways the picture fits the frame;
    /// standing upright, an upright center crop fills it, as webcam apps do.
    private fun turn() {
        val sensor = chars.get(CameraCharacteristics.SENSOR_ORIENTATION) ?: 90
        val device = if (lens.facing == "front") -held else held
        val upright = (sensor + device + 360) % 360
        val landscapeHeld = upright % 180 == 0
        if (orientationMode == "portrait") {
            if (!landscapeHeld) lastPortrait = upright
            // Never held upright yet: the usual upright hold.
            renderer.rotation = if (lastPortrait >= 0) lastPortrait else if (sensor % 180 == 90) sensor else (sensor + 90) % 360
            renderer.fill = false
        } else {
            renderer.rotation = upright
            renderer.fill = !landscapeHeld
        }
    }

    /// A point of the camera's picture (0..1 across and down) as a
    /// metering area. With the zoom ratio API the coordinates are those of
    /// the zoomed picture; with a crop they're the cropped part of the sensor.
    private fun metering(point: Pair<Float, Float>, active: Rect): MeteringRectangle {
        val ratioApi = Build.VERSION.SDK_INT >= 30 && zoomRange().lower != zoomRange().upper
        val area = if (ratioApi || zoom <= 1f) Rect(0, 0, active.width(), active.height()) else {
            val w = (active.width() / zoom).toInt()
            val h = (active.height() / zoom).toInt()
            Rect(active.width() / 2 - w / 2, active.height() / 2 - h / 2, active.width() / 2 + w / 2, active.height() / 2 + h / 2)
        }
        // The stream is a 16:9 cut of the sensor's picture.
        // The camera delivers a cut of its sensor in its output's shape.
        val visibleH = min(area.height().toFloat(), area.width() * input.height / input.width.toFloat())
        val visibleW = min(area.width().toFloat(), area.height() * input.width / input.height.toFloat())
        val x = area.left + (area.width() - visibleW) / 2 + point.first * visibleW
        val y = area.top + (area.height() - visibleH) / 2 + point.second * visibleH
        val half = max(area.width(), area.height()) / 20
        return MeteringRectangle(
            Rect((x - half).toInt().coerceAtLeast(0), (y - half).toInt().coerceAtLeast(0),
                (x + half).toInt().coerceAtMost(active.width() - 1), (y + half).toInt().coerceAtMost(active.height() - 1)),
            MeteringRectangle.METERING_WEIGHT_MAX - 1,
        )
    }

    // What this camera can do.

    private fun zoomRange(): Range<Float> =
        if (Build.VERSION.SDK_INT >= 30) chars.get(CameraCharacteristics.CONTROL_ZOOM_RATIO_RANGE) ?: Range(1f, maxCrop())
        else Range(1f, maxCrop())

    private fun maxCrop() = chars.get(CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM) ?: 1f
    private fun hasFlash() = chars.get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
    private fun maxRegions(key: CameraCharacteristics.Key<Int>) = chars.get(key) ?: 0
    private fun afModes() = chars.get(CameraCharacteristics.CONTROL_AF_AVAILABLE_MODES)?.toList().orEmpty()
    private fun autoFocus() = CameraMetadata.CONTROL_AF_MODE_AUTO in afModes()
    private fun manualFocus() = (chars.get(CameraCharacteristics.LENS_INFO_MINIMUM_FOCUS_DISTANCE) ?: 0f) > 0f
    private fun videoStabilization() = chars.get(CameraCharacteristics.CONTROL_AVAILABLE_VIDEO_STABILIZATION_MODES)
        ?.contains(CameraMetadata.CONTROL_VIDEO_STABILIZATION_MODE_ON) == true
    private fun opticalStabilization() = chars.get(CameraCharacteristics.LENS_INFO_AVAILABLE_OPTICAL_STABILIZATION)
        ?.contains(CameraMetadata.LENS_OPTICAL_STABILIZATION_MODE_ON) == true

    private val awbNames = mapOf(
        "auto" to CameraMetadata.CONTROL_AWB_MODE_AUTO,
        "daylight" to CameraMetadata.CONTROL_AWB_MODE_DAYLIGHT,
        "cloudy" to CameraMetadata.CONTROL_AWB_MODE_CLOUDY_DAYLIGHT,
        "shade" to CameraMetadata.CONTROL_AWB_MODE_SHADE,
        "incandescent" to CameraMetadata.CONTROL_AWB_MODE_INCANDESCENT,
        "fluorescent" to CameraMetadata.CONTROL_AWB_MODE_FLUORESCENT,
    )

    private fun awbModes(): List<String> {
        val have = chars.get(CameraCharacteristics.CONTROL_AWB_AVAILABLE_MODES)?.toSet().orEmpty()
        return awbNames.filterValues { it in have }.keys.toList()
    }

    private fun awbMode(name: String) = awbNames[name]?.takeIf { it in (chars.get(CameraCharacteristics.CONTROL_AWB_AVAILABLE_MODES)?.toSet().orEmpty()) }
        ?: CameraMetadata.CONTROL_AWB_MODE_AUTO

    /// More frames need more bits for the same sharpness.
    private fun bitrate(quality: String) = when (quality) {
        "saver" -> 2_000_000
        "high" -> 8_000_000
        else -> 4_000_000
    } * (if (fps >= 60) 3 else 2) / 2 * (if (size.width >= 1920) 3 else 2) / 2

    /// A new encoder at the current frame rate; the renderer draws into it
    /// before the old one stops, so the stream goes on (with a keyframe).
    private fun restartEncoder() {
        val old = encoder
        encoder = H264Encoder(size.width, size.height, bitrate = bitrate(quality), fps = fps, label = "Webcam", session = session, onEnded = onEnded)
        renderer.setOutput(encoder.inputSurface, encoder.width, encoder.height)
        old.stop()
    }

    // Frame rate.

    /// The auto-exposure range for [target] fps: steady at it if possible.
    private fun fpsRange(target: Int): Range<Int>? {
        val ranges = chars.get(CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES).orEmpty()
        return ranges.filter { it.upper == target }.maxByOrNull { it.lower }
            ?: ranges.filter { it.upper >= target }.minByOrNull { it.upper }
    }

    /// Whether this camera does 60 fps in an ordinary session at a usable size.
    private fun can60(): Boolean =
        chars.get(CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES).orEmpty().any { it.upper >= 60 } &&
            outputSizes(chars, 60).isNotEmpty()

    /// Whether this camera delivers a full 1920-wide 16:9 picture at the
    /// current frame rate (else 1080p would only be scaled up).
    private fun can1080(): Boolean =
        outputSizes(chars, fps).any { it.width >= 1920 && it.width * 9 == it.height * 16 }

    /// Zoom presets like a camera app's: the widest the camera reaches
    /// (0.6× on a logical camera with an ultra-wide), 1×, 2×, 3×, 5×, 10×
    /// within its range, and separate lenses of the same facing.
    private fun presets(): List<Float> {
        val range = zoomRange()
        val out = mutableListOf<Float>()
        if (range.lower < 0.95f) out += (range.lower * 10).roundToInt() / 10f
        out += 1f
        for (z in listOf(2f, 3f, 5f, 10f)) if (z <= range.upper + 0.01f) out += z
        return out
    }

    // Controls.

    /// The capabilities and the current controls, for the phone's screen and
    /// the computer (docs/android-app.md, `camera_state`).
    fun state(): JSONObject {
        val range = zoomRange()
        val ev = chars.get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)
        val step = chars.get(CameraCharacteristics.CONTROL_AE_COMPENSATION_STEP)
        return JSONObject()
            .put("width", size.width).put("height", size.height)
            .put("facing", lens.facing)
            .put("lens", lens.id)
            .put("lenses", org.json.JSONArray().apply {
                lenses.forEach {
                    put(JSONObject().put("id", it.id).put("facing", it.facing).put("zoom", it.equivalent).put("main", it.main))
                }
            })
            .put("zoom", zoom.toDouble())
            .put("zoom_min", range.lower.toDouble()).put("zoom_max", range.upper.toDouble())
            .put("zoom_presets", org.json.JSONArray(presets().map { it.toDouble() }))
            .put("torch", torch).put("has_torch", hasFlash())
            .put("focus", focus)
            .put("focus_modes", org.json.JSONArray(buildList {
                add("auto")
                if (autoFocus() && maxRegions(CameraCharacteristics.CONTROL_MAX_REGIONS_AF) > 0) add("point")
                if (manualFocus()) add("manual")
            }))
            .put("focus_distance", focusDistance.toDouble())
            .put("focus_point", focusPoint?.let { org.json.JSONArray(listOf(it.first.toDouble(), it.second.toDouble())) } ?: JSONObject.NULL)
            .put("exposure", exposure)
            .put("exposure_min", ev?.lower ?: 0).put("exposure_max", ev?.upper ?: 0)
            .put("exposure_step", step?.toDouble() ?: 0.0)
            .put("exposure_lock", exposureLock)
            .put("white_balance", whiteBalance)
            .put("white_balances", org.json.JSONArray(awbModes()))
            .put("white_balance_lock", whiteBalanceLock)
            .put("stabilization", stabilization)
            .put("has_stabilization", videoStabilization() || opticalStabilization())
            .put("quality", quality)
            .put("fps", fps)
            .put("fps_options", org.json.JSONArray(if (can60()) listOf(30, 60) else listOf(30)))
            .put("size_options", org.json.JSONArray().apply {
                put(org.json.JSONArray(listOf(HD.width, HD.height)))
                if (can1080()) put(org.json.JSONArray(listOf(FULL_HD.width, FULL_HD.height)))
            })
            .put("camera_width", input.width).put("camera_height", input.height)
            .put("rotation", renderer.rotation)
            .put("orientation", orientationMode)
    }

    /// Applies any of the controls in [c] (the same names as [state]).
    fun set(c: JSONObject) = handler.post {
        if (stopped) return@post
        var reopen: Lens? = null
        var trigger = false
        if (c.has("facing")) {
            val facing = c.getString("facing")
            if (facing != lens.facing) reopen = lenses.firstOrNull { it.facing == facing && it.main } ?: lenses.firstOrNull { it.facing == facing }
        }
        if (c.has("lens")) reopen = lenses.firstOrNull { it.id == c.getString("lens") }?.takeIf { it.id != lens.id } ?: reopen
        if (c.has("zoom")) zoom = c.getDouble("zoom").toFloat()
        if (c.has("torch")) torch = c.getBoolean("torch")
        if (c.has("focus")) {
            focus = c.getString("focus")
            if (focus == "auto") focusPoint = null
        }
        if (c.has("focus_point")) {
            val p = c.optJSONArray("focus_point")
            if (p != null && p.length() == 2) {
                focusPoint = p.getDouble(0).toFloat().coerceIn(0f, 1f) to p.getDouble(1).toFloat().coerceIn(0f, 1f)
                if (!c.has("focus")) focus = "point"
                trigger = focus == "point"
            }
        }
        if (c.has("focus_distance")) focusDistance = c.getDouble("focus_distance").toFloat().coerceIn(0f, 1f)
        if (c.has("exposure")) exposure = c.getInt("exposure")
        if (c.has("exposure_lock")) exposureLock = c.getBoolean("exposure_lock")
        if (c.has("white_balance")) whiteBalance = c.getString("white_balance")
        if (c.has("white_balance_lock")) whiteBalanceLock = c.getBoolean("white_balance_lock")
        if (c.has("stabilization")) stabilization = c.getBoolean("stabilization")
        if (c.has("orientation")) orientationMode = if (c.getString("orientation") == "portrait") "portrait" else "landscape"
        var reconfigure = false
        if (c.has("fps")) {
            val wanted = if (c.optInt("fps", 30) >= 60 && can60()) 60 else 30
            if (wanted != fps) {
                fps = wanted
                reconfigure = true
            }
        }
        // 1080p: a new encoder at that size, SPS/PPS and a keyframe first.
        if (c.has("size")) {
            val asked = c.optJSONArray("size")
            val wanted = if (asked != null && asked.optInt(0) >= 1920 && can1080()) FULL_HD else HD
            if (wanted != size) {
                size = wanted
                reconfigure = true
            }
        }
        if (c.has("quality")) quality = c.getString("quality")
        if (c.has("quality") && !reconfigure) encoder.setBitrate(bitrate(quality))
        turn()
        when {
            reopen != null -> switchTo(reopen)
            // Another frame rate may need another camera size: a new session.
            reconfigure -> {
                clamp()
                restartEncoder()
                configure()
            }
            else -> {
                clamp()
                apply(trigger)
            }
        }
    }

    /// Front ↔ back, same stream. False when there's no other camera.
    fun switch(): Boolean {
        val other = if (lens.facing == "back") "front" else "back"
        if (lenses.none { it.facing == other }) return false
        set(JSONObject().put("facing", other))
        return true
    }

    private fun switchTo(next: Lens) {
        runCatching { capture?.close() }
        runCatching { device?.close() }
        capture = null
        device = null
        lens = next
        chars = manager.getCameraCharacteristics(next.id)
        // What the new camera can't do goes back to its default.
        zoom = 1f
        focus = "auto"
        focusPoint = null
        exposure = 0
        if (!hasFlash()) torch = false
        if (fps == 60 && !can60()) {
            fps = 30
            restartEncoder()
        }
        clamp()
        turn()
        open()
    }

    private fun clamp() {
        val range = zoomRange()
        zoom = zoom.coerceIn(range.lower, range.upper)
        val ev = chars.get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)
        if (ev != null) exposure = exposure.coerceIn(ev.lower, ev.upper)
        if (focus == "manual" && !manualFocus()) focus = "auto"
        if (whiteBalance !in awbModes()) whiteBalance = "auto"
    }

    /// Shows the stream on the phone too ([surface] null: stops showing it).
    fun setPreview(surface: Surface?) {
        if (!stopped) renderer.setPreview(surface)
    }

    /// `camera_control` from the computer: framed JSON (u32 big-endian length
    /// + body) on the session's stream, the same keys as [set].
    private fun readControls() {
        var pending = ByteArray(0)
        while (!stopped) {
            val chunk = NativeSession.read(session) ?: return
            pending += chunk
            while (pending.size >= 4) {
                val len = ((pending[0].toInt() and 0xff) shl 24) or ((pending[1].toInt() and 0xff) shl 16) or
                    ((pending[2].toInt() and 0xff) shl 8) or (pending[3].toInt() and 0xff)
                if (len < 0 || len > 64 * 1024) return
                if (pending.size < 4 + len) break
                val body = String(pending, 4, len, Charsets.UTF_8)
                pending = pending.copyOfRange(4 + len, pending.size)
                runCatching { JSONObject(body) }.getOrNull()
                    ?.takeIf { it.optString("type") == "camera_control" }
                    ?.let { set(it) }
            }
        }
    }

    override fun stop() {
        stopped = true
        orientation.disable()
        handler.post {
            runCatching { capture?.close() }
            runCatching { device?.close() }
        }
        renderer.stop()
        encoder.stop()
        thread.quitSafely()
    }

    private companion object {
        val HD = Size(1280, 720)
        val FULL_HD = Size(1920, 1080)

        /// Sizes this camera delivers to a texture at [fps], up to 1920 wide.
        fun outputSizes(chars: CameraCharacteristics, fps: Int): List<Size> {
            val map = chars.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP) ?: return emptyList()
            val frame = 1_000_000_000L / fps + 500_000 // ns, a little slack
            return map.getOutputSizes(android.graphics.SurfaceTexture::class.java).orEmpty()
                .filter { it.width <= 1920 && it.height <= 1920 }
                .filter { runCatching { map.getOutputMinFrameDuration(android.graphics.SurfaceTexture::class.java, it) }.getOrDefault(0L) <= frame }
        }

        /// The camera's output for the 1280×720 stream: exactly that when it
        /// offers it, else the closest 16:9 size (the smallest at least 1280
        /// wide, or the largest below), else the closest shape. The renderer
        /// fits whatever it gets, so it never stretches.
        fun cameraSize(chars: CameraCharacteristics, fps: Int, stream: Size): Size {
            val sizes = outputSizes(chars, fps).ifEmpty { outputSizes(chars, 30) }
            if (sizes.isEmpty()) return stream
            stream.takeIf { it in sizes }?.let { return it }
            val wide = sizes.filter { it.width * 9 == it.height * 16 }
            wide.filter { it.width >= stream.width }.minByOrNull { it.width }?.let { return it }
            wide.maxByOrNull { it.width }?.let { return it }
            return sizes.minWith(
                compareBy<Size> { kotlin.math.abs(it.width.toFloat() / it.height - 16f / 9) }.thenByDescending { it.width },
            )
        }
    }
}
