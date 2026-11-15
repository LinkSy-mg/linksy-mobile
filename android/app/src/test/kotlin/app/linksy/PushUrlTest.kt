package app.linksy

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class PushUrlTest {
    @Test
    fun keepsHttpsLinks() {
        assertEquals("https://linksy.diary.mg/news", Push.safeLink("https://linksy.diary.mg/news"))
        assertEquals("HTTPS://linksy.diary.mg", Push.safeLink("HTTPS://linksy.diary.mg"))
    }

    @Test
    fun dropsPlainHttp() {
        assertNull(Push.safeLink("http://linksy.diary.mg/news"))
    }

    @Test
    fun dropsOtherSchemesAndJunk() {
        assertNull(Push.safeLink("intent://scan/#Intent;scheme=zxing;end"))
        assertNull(Push.safeLink("file:///sdcard/x"))
        assertNull(Push.safeLink("javascript:alert(1)"))
        assertNull(Push.safeLink("linksy://pair/abc"))
        assertNull(Push.safeLink(" https://example.com"))
        assertNull(Push.safeLink(""))
        assertNull(Push.safeLink(null))
    }
}
