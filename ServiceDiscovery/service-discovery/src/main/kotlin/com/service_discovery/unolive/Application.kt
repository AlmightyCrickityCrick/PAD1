package com.service_discovery.unolive

import RegisterModel
import com.service_discovery.unolive.plugins.*
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*


var registeredServices = ArrayList<RegisterModel>()
lateinit var gateway: RegisterModel
var taskTimeoutLimitSeconds: Long = 10
var busyServices = ArrayList<RegisterModel>()
fun main() {
    HealthMonitor().start()

    embeddedServer(Netty, port = 8080, host = "0.0.0.0", module = Application::module)
        .start(wait = true)
}

fun Application.module() {
    configureRouting()
}
