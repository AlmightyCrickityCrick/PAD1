package com.unolive.plugins

import com.service_discovery.unolive.models.DatabaseState
import com.service_discovery.unolive.models.HealthModel
import com.service_discovery.unolive.models.LoadState
import com.unolive.*
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.json.Json
import io.ktor.server.plugins.ratelimit.*
import kotlinx.serialization.json.JsonElement
import kotlin.time.Duration.Companion.seconds


fun Application.configureRouting() {
    install(ContentNegotiation) {
        json()
    }
    install(RateLimit) {
        global {
            rateLimiter(limit = 60, refillPeriod = 60.seconds)
        }
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

fun Application.configureRankingRouting(){
    routing {
        post("/login"){
            val cr = currentRankingService.getAndIncrement() % rankingServices.size
            val b = call.receive<String>()
            var resp: HttpResponse = rankingClient.post("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/login"){
                contentType(ContentType.Application.Json)
                accept(ContentType.Application.Json)
                setBody(b)
            }
            call.respond(resp.status, resp.body<String>())
        }

        post("/register"){
            val cr = currentRankingService.getAndIncrement() % rankingServices.size
            val b = call.receive<String>()
            var resp: HttpResponse = rankingClient.post("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/register"){
                contentType(ContentType.Application.Json)
                accept(ContentType.Application.Json)
                setBody(b)
            }
            call.respond(resp.status, resp.body<String>())
        }

        get("/user/{id}"){
            val cr = currentRankingService.getAndIncrement() % rankingServices.size
            var resp: HttpResponse = rankingClient.get("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/user/${call.parameters["id"]}"){
                accept(ContentType.Application.Json)
            }
            call.respond(resp.status, resp.body<String>())
        }

        get("/user/{id}/friends"){
            val cr = currentRankingService.getAndIncrement() % rankingServices.size
            var resp: HttpResponse = rankingClient.get("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/user/${call.parameters["id"]}/friends"){
                accept(ContentType.Application.Json)
            }
            call.respond(resp.status, resp.body<String>())
        }

        post("/befriend/{user_id}"){
            val cr = currentRankingService.getAndIncrement() % rankingServices.size
            var resp: HttpResponse = rankingClient.post("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/befriend/${call.parameters["user_id"]}"){
                contentType(ContentType.Application.Json)
                accept(ContentType.Application.Json)
                setBody(call.receive<String>())
            }
            call.respond(resp.status)
        }

        post("/unfriend/{user_id}"){
            val cr = currentRankingService.getAndIncrement() % rankingServices.size
            var resp: HttpResponse = rankingClient.post("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/unfriend/${call.parameters["user_id"]}"){
                contentType(ContentType.Application.Json)
                accept(ContentType.Application.Json)
                setBody(call.receive<String>())
            }
            call.respond(resp.status)
        }
    }

}

fun Application.configureGamingToRankingRouting(){
    routing{
        post("/changeRank"){

        }

        post("/banUser"){

        }
    }
}

fun Application.configureGamingRouting(){
    routing{

        get("/getGames/:userid"){

        }

        post("/join"){

        }

        post("/exit/:lobby_id"){

        }


    }

}
