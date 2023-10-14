package com.service_discovery.unolive.plugins

import RegisterModel
import com.service_discovery.unolive.gateway
import com.service_discovery.unolive.models.DatabaseState
import com.service_discovery.unolive.models.HealthModel
import com.service_discovery.unolive.models.LoadState
import com.service_discovery.unolive.registeredServices
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.plugins.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.encodeToJsonElement

fun Application.configureRouting() {
    install(ContentNegotiation) {
        json()
    }
    routing {
        get("/") {
            call.respond(mapOf("hello" to "world"))
        }

        post("/register"){
            try {
                var body = call.receive<String>()
                var service = Json.decodeFromString(RegisterModel.serializer(), body)
                if (service.address == null) service.address = call.request.origin.remoteAddress
                println("New Service Registered ${service.type} ${service.address} ${service.internal_port}")
                registeredServices.add(service)
                if (service.type == ServiceType.gateway_service) gateway = service
                call.respond(HttpStatusCode.Created)

//            if(service.type != ServiceType.gateway_service)
                //TODO:Send via gRPC the service info
            } catch (err : Error) {
                println(err)
                println("Incorrect register content")
                call.respond(HttpStatusCode.BadRequest)
            }

        }

        post("/getHealth"){
            call.respond(HttpStatusCode.OK, Json.encodeToJsonElement(HealthModel.serializer(), HealthModel(DatabaseState.none, LoadState.ok)))
        }
    }
}
