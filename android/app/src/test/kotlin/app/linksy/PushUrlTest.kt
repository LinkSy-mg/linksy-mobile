package app.linksy

import org.junit.Assert.assertEquals
import org.junit.Test

/// Plain JVM tests: android.jar is stubbed here, so these cover the decision
/// (`linkOrApp`, which `tapIntent` and so `show` go through), not Uri parsing.
class PushUrlTest {
    private fun pick(scheme: String?) = Push.linkOrApp(scheme, { "link" }, { "app" })

    @Test
    fun httpsOpensTheLink() = assertEquals("link", pick("https"))

    @Test
    fun plainHttpFallsBackToTheApp() = assertEquals("app", pick("http"))

    @Test
    fun otherSchemesAndJunkFallBackToTheApp() {
        for (s in listOf("intent", "file", "javascript", "linksy", " https", "HTTPS", "", null)) {
            assertEquals("scheme $s", "app", pick(s))
        }
    }
}
