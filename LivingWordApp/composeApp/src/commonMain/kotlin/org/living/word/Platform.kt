package org.living.word

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform