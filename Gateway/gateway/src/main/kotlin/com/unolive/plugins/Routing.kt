package com.unolive.plugins

import com.service_discovery.unolive.models.DatabaseState
import com.service_discovery.unolive.models.HealthModel
import com.service_discovery.unolive.models.LoadState
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.json.Json

fun Application.configureRouting() {
    install(ContentNegotiation) {
        json()
    }
    routing {
        get("/") {
            call.respondText("Hello World!")
        }

        post("/getHealth"){
            call.respond(HttpStatusCode.OK, Json.encodeToString(HealthModel.serializer(), HealthModel(DatabaseState.none, LoadState.ok)))
        }
    }
}
