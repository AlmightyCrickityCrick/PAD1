package com.unolive

import RegisterModel
import com.service_discovery.unolive.models.HealthModel
import com.unolive.plugins.*
import io.grpc.ServerBuilder
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.serialization.json.Json
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicInteger

var taskTimeoutLimitSeconds: Long = 10

var client = HttpClient() {
    install(HttpTimeout) {
        requestTimeoutMillis = taskTimeoutLimitSeconds * 1000
    }
}

var rankingClient = HttpClient() {
    install(HttpTimeout) {
        requestTimeoutMillis = taskTimeoutLimitSeconds * 1000
    }
}

var gameClient = HttpClient() {
    install(HttpTimeout) {
        requestTimeoutMillis = taskTimeoutLimitSeconds * 1000
    }
}

var rankingServices = ArrayList<RegisterModel>()
var currentRankingService = AtomicInteger(0)

var gamingServices = ConcurrentHashMap<String, Int>()
var gamingServiceInfo = ConcurrentHashMap<String, RegisterModel>()
fun main() {
    val server = ServerBuilder
        .forPort(7070)
        .addService(ServiceRegistrationServer())
        .build()
    server.start()

    registerSelf()


    embeddedServer(Netty, port = 8080, host = "0.0.0.0", module = Application::module)
        .start(wait = true)
}

fun Application.module() {
    configureHTTP()
    configureRouting()
    configureRankingRouting()
    configureGamingRouting()
    configureGamingToRankingRouting()
}

fun registerSelf(){
    try {
        runBlocking {
            var job = launch {
                var resp: HttpResponse = client.post("http://service_discovery:8080/register"){
                    setBody(Json.encodeToString(RegisterModel.serializer(), RegisterModel(
                        type = ServiceType.gateway_service,
                        internal_port = 8080,
                        external_port = 8080
                    )))
                }
            }
        }
    } catch (er: Exception) {
        println("Service Discovery not up yet")
    }
}