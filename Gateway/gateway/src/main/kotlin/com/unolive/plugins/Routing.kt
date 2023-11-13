package com.unolive.plugins

import com.service_discovery.unolive.models.DatabaseState
import com.service_discovery.unolive.models.HealthModel
import com.service_discovery.unolive.models.LoadState
import com.unolive.*
import io.ktor.client.call.*
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
import kotlin.time.Duration.Companion.seconds


fun Application.configureRouting() {
    install(ContentNegotiation) {
        json()
    }
    install(RateLimit) {
        register(RateLimitName("user_requests")) {
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
        rateLimit(RateLimitName("user_requests")) {
            post("/login") {
                if(rankingServices.size == 0) call.respond(HttpStatusCode.ServiceUnavailable, "Sorry, service unavailable")
                else {
                    var cr = currentRankingService.getAndIncrement() % rankingServices.size
                    var servicesPinged = 1
                    var requestSuccessful = false
                    var response: Pair<Boolean, HttpResponse?>
                    var resp: HttpResponse
                    while (servicesPinged <= rankingServices.size  && !requestSuccessful){
                        response = sendRankingRequest("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/login", call.receive<String>(), 1 )
                        if (response.first){
                            resp = response.second!!
                            requestSuccessful = true
                            call.respond(resp.status, resp.body<String>())
                            break
                        } else{
                            servicesPinged++;
                            cr += 1 % rankingServices.size
                        }
                    }
                    if(!requestSuccessful) call.respond(HttpStatusCode.ServiceUnavailable, "Something went wrong")
                }
            }

            post("/register") {
                if(rankingServices.size == 0) call.respond(HttpStatusCode.ServiceUnavailable, "Sorry, service unavailable")
                else {
                    var cr = currentRankingService.getAndIncrement() % rankingServices.size
                    var servicesPinged = 1
                    var requestSuccessful = false
                    var response: Pair<Boolean, HttpResponse?>
                    var resp: HttpResponse
                    while (servicesPinged <= rankingServices.size  && !requestSuccessful){
                        response = sendRankingRequest("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/register", call.receive<String>(), 1 )
                        if (response.first){
                            resp = response.second!!
                            requestSuccessful = true
                            call.respond(resp.status,  resp.body<String>())
                            break
                        } else{
                            servicesPinged++;
                            cr += 1 % rankingServices.size
                        }
                    }
                    if(!requestSuccessful) call.respond(HttpStatusCode.ServiceUnavailable, "Something went wrong")
                }
            }

            get("/user/{id}") {
                if(rankingServices.size == 0) call.respond(HttpStatusCode.ServiceUnavailable, "Sorry, service unavailable")
                else {
                    var cr = currentRankingService.getAndIncrement() % rankingServices.size
                    var servicesPinged = 1
                    var requestSuccessful = false
                    var response: Pair<Boolean, HttpResponse?>
                    var resp: HttpResponse
                    while (servicesPinged <= rankingServices.size  && !requestSuccessful){
                        response = sendRankingRequest("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/user/${call.parameters["id"]}", 1 )
                        if (response.first){
                            resp = response.second!!
                            requestSuccessful = true
                            call.respond(resp.status, resp.body<String>())
                            break
                        } else{
                            servicesPinged++;
                            cr += 1 % rankingServices.size
                        }
                    }
                    if(!requestSuccessful) call.respond(HttpStatusCode.ServiceUnavailable, "Something went wrong")
                }
            }

            get("/user/{id}/friends") {
                if(rankingServices.size == 0) call.respond(HttpStatusCode.ServiceUnavailable, "Sorry, service unavailable")
                else {
                    var cr = currentRankingService.getAndIncrement() % rankingServices.size
                    var servicesPinged = 1
                    var requestSuccessful = false
                    var response: Pair<Boolean, HttpResponse?>
                    var resp: HttpResponse
                    while (servicesPinged <= rankingServices.size  && !requestSuccessful){
                        response = sendRankingRequest("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/user/${call.parameters["id"]}/friends", 1 )
                        if (response.first){
                            resp = response.second!!
                            requestSuccessful = true
                            call.respond(resp.status, resp.body<String>())
                            break
                        } else{
                            servicesPinged++;
                            cr += 1 % rankingServices.size
                        }
                    }
                    if(!requestSuccessful) call.respond(HttpStatusCode.ServiceUnavailable)
                }
            }

            post("/befriend/{user_id}") {
                if(rankingServices.size == 0) call.respond(HttpStatusCode.ServiceUnavailable, "Sorry, service unavailable")
                else {
                    var cr = currentRankingService.getAndIncrement() % rankingServices.size
                    var servicesPinged = 1
                    var requestSuccessful = false
                    var response: Pair<Boolean, HttpResponse?>
                    var resp: HttpResponse
                    while (servicesPinged <= rankingServices.size  && !requestSuccessful){
                        response = sendRankingRequest("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/befriend/${call.parameters["user_id"]}", call.receive<String>(), 1 )
                        if (response.first){
                            resp = response.second!!
                            requestSuccessful = true
                            call.respond(resp.status)
                            break
                        } else{
                            servicesPinged++;
                            cr += 1 % rankingServices.size
                        }
                    }
                    if(!requestSuccessful) call.respond(HttpStatusCode.ServiceUnavailable, "Something went wrong")
                }
            }

            post("/unfriend/{user_id}") {
                if(rankingServices.size == 0) call.respond(HttpStatusCode.ServiceUnavailable, "Sorry, service unavailable")
                else {
                    var cr = currentRankingService.getAndIncrement() % rankingServices.size
                    var servicesPinged = 1
                    var requestSuccessful = false
                    var response: Pair<Boolean, HttpResponse?>
                    var resp: HttpResponse
                    while (servicesPinged <= rankingServices.size  && !requestSuccessful){
                        response = sendRankingRequest("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/unfriend/${call.parameters["user_id"]}", call.receive<String>(), 1 )
                        if (response.first){
                            resp = response.second!!
                            requestSuccessful = true
                            call.respond(resp.status)
                            break
                        } else{
                            servicesPinged++;
                            cr += 1 % rankingServices.size
                        }
                    }
                    if(!requestSuccessful) call.respond(HttpStatusCode.ServiceUnavailable)
                }
            }
        }
    }

}

fun Application.configureGamingToRankingRouting(){
    routing{
        post("/changeRank"){
            var cr = currentRankingService.getAndIncrement() % rankingServices.size
            var servicesPinged = 1
            var requestSuccessful = false
            var response: Pair<Boolean, HttpResponse?>
            var resp: HttpResponse
            while (servicesPinged <= rankingServices.size  && !requestSuccessful){
                response = sendRankingRequest("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/changeRank", call.receive<String>(), 1 )
                if (response.first){
                    resp = response.second!!
                    requestSuccessful = true
                    call.respond(resp.status)
                    break
                } else{
                    servicesPinged++;
                    cr += 1 % rankingServices.size
                }
            }
            if(!requestSuccessful) call.respond(HttpStatusCode.ServiceUnavailable)

        }

        post("/banUser"){
            var cr = currentRankingService.getAndIncrement() % rankingServices.size
            var servicesPinged = 1
            var requestSuccessful = false
            var response: Pair<Boolean, HttpResponse?>
            var resp: HttpResponse
            while (servicesPinged <= rankingServices.size  && !requestSuccessful){
                response = sendRankingRequest("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/banUser", call.receive<String>(), 1 )
                if (response.first){
                    resp = response.second!!
                    requestSuccessful = true
                    call.respond(resp.status)
                    break
                } else{
                    servicesPinged++;
                    cr += 1 % rankingServices.size
                }
            }
            if(!requestSuccessful) call.respond(HttpStatusCode.ServiceUnavailable)
        }

        post("/addGame"){
            val body = call.receive<String>()
            val request1Res = handleGameCreationRanking(body)
            if (!request1Res.first || request1Res.second?.status != HttpStatusCode.OK){
                println("------------------------- Couldnt increase ranking ------------------------")
                val request1Comp = handleGameCreationRankingFail(body)
                call.respond(HttpStatusCode.ServiceUnavailable, "Something went wrong")
            }
            else{
                val request2Res = handleGameCreationGaming(body)
                if (!request2Res.first || request2Res.second?.status != HttpStatusCode.Created) {
                    println("------------------------- Couldnt add the game ------------------------")
                    val request1Comp = handleGameCreationRankingFail(body)
                    if (!request1Comp.first || request1Comp.second?.status != HttpStatusCode.OK) println("------------------------- Couldnt decrease ranking. Please perform manual check ------------------------")
                    call.respond(HttpStatusCode.ServiceUnavailable, "Something went wrong")
                } else{
                    call.respond(HttpStatusCode.OK, "Game added")
                }
            }
        }
    }
}

fun Application.configureGamingRouting(){
    routing{
        rateLimit(RateLimitName("user_requests")) {
        get("/getGames/{user_id}"){
            if(currentGameService == "") call.respond(HttpStatusCode.ServiceUnavailable, "Sorry, service unavailable")
            else{
                var cr = currentGameService
                var servicesPinged = 1
                var candidateCR = gamingServices.keys().toList().toMutableList()
                var requestSuccessful = false
                var response: Pair<Boolean, HttpResponse?>
                var resp: HttpResponse
                while (servicesPinged <= gamingServices.size  && !requestSuccessful){
                    response = sendGameRequest("http://${gamingServiceInfo[cr]!!.address}:${gamingServiceInfo[cr]!!.internal_port}/getGames/${call.parameters["user_id"]}", 1)
                    if (response.first){
                        resp = response.second!!
                        requestSuccessful = true
                        call.respond(resp.status, resp.body<String>())
                        break
                    } else{
                        servicesPinged++;
                        candidateCR.remove(cr)
                        cr =  candidateCR.random()
                    }
                }

               if(!requestSuccessful) call.respond(HttpStatusCode.ServiceUnavailable, "Something went wrong")
            }

        }

        post("/join"){
            val cr = currentGameService
            if(currentGameService == "") call.respond(HttpStatusCode.ServiceUnavailable, "Sorry, service unavailable")
            else {
                var cr = currentGameService
                var servicesPinged = 1
                var candidateCR = gamingServices.keys().toList().toMutableList()
                var requestSuccessful = false
                var response: Pair<Boolean, HttpResponse?>
                var resp: HttpResponse
                while (servicesPinged <= gamingServices.size  && !requestSuccessful){
                    response = sendGameRequest("http://${gamingServiceInfo[cr]!!.address}:${gamingServiceInfo[cr]!!.internal_port}/join", call.receive<String>(), 1)
                    if (response.first){
                        resp = response.second!!
                        requestSuccessful = true
                        call.respond(resp.status, resp.body<String>().replaceFirst("/", ":${gamingServiceInfo[cr]!!.external_port}/"))
                        break
                    } else{
                        servicesPinged++;
                        candidateCR.remove(cr)
                        cr =  candidateCR.random()
                    }
                }

                if(!requestSuccessful) call.respond(HttpStatusCode.ServiceUnavailable, "Something went wrong")
            }
        }

        post("/privatejoin"){
            val cr = currentGameService
            if(currentGameService == "") call.respond(HttpStatusCode.ServiceUnavailable, "Sorry, service unavailable")
            else {
                var cr = currentGameService
                var servicesPinged = 1
                var candidateCR = gamingServices.keys().toList().toMutableList()
                var requestSuccessful = false
                var response: Pair<Boolean, HttpResponse?>
                var resp: HttpResponse
                while (servicesPinged <= gamingServices.size  && !requestSuccessful){
                    response = sendGameRequest("http://${gamingServiceInfo[cr]!!.address}:${gamingServiceInfo[cr]!!.internal_port}/privatejoin", call.receive<String>(), 1)
                    if (response.first){
                        resp = response.second!!
                        requestSuccessful = true
                        call.respond(resp.status, resp.body<String>().replaceFirst("/", ":${gamingServiceInfo[cr]!!.external_port}/"))
                        break
                    } else{
                        servicesPinged++;
                        candidateCR.remove(cr)
                        cr =  candidateCR.random()
                    }
                }

                if(!requestSuccessful) call.respond(HttpStatusCode.ServiceUnavailable, "Something went wrong")
            }
        }

        }


    }

}

suspend fun sendGameRequest(address: String, attempt: Int): Pair<Boolean, HttpResponse?>{
    try{
        var resp: HttpResponse = gameClient.get(address){
            accept(ContentType.Application.Json)
        }
        return Pair(true, resp)
    }catch(e: Error){
        return if (attempt < 3) sendGameRequest(address, attempt + 1)
        else{
            println("The service couldnt be reached")
            Pair(false, null)
        }
    }
}

suspend fun sendGameRequest(address: String, body: String, attempt: Int): Pair<Boolean, HttpResponse?>{
    try{
        var resp: HttpResponse =
            gameClient.post(address) {
                contentType(ContentType.Application.Json)
                accept(ContentType.Application.Json)
                setBody(body)
            }
        return Pair(true, resp)
    }catch(e: Error){
        return if (attempt < 3) sendGameRequest(address, body,attempt + 1)
        else{
            println("The service couldnt be reached")
            Pair(false, null)
        }
    }
}

suspend fun sendRankingRequest(address: String,  attempt: Int) : Pair<Boolean, HttpResponse?>{
    try{
        var resp: HttpResponse =
            rankingClient.get(address) {
                accept(ContentType.Application.Json)
            }
        return Pair(true, resp)
    }catch(e: Error){
        return if (attempt < 3) sendRankingRequest(address, attempt + 1)
        else{
            println("The service couldnt be reached")
            Pair(false, null)
        }
    }
}

suspend fun sendRankingRequest(address: String, body: String,  attempt: Int) : Pair<Boolean, HttpResponse?>{
    try{
        var resp: HttpResponse = rankingClient.post(address){
            contentType(ContentType.Application.Json)
            accept(ContentType.Application.Json)
            setBody(body)
        }
        return Pair(true, resp)
    }catch(e: Error){
        return if (attempt < 3) sendRankingRequest(address, body,attempt + 1)
        else{
            println("The service couldnt be reached")
            Pair(false, null)
        }
    }
}

suspend fun handleGameCreationRanking(body:String): Pair<Boolean, HttpResponse?>{
    var cr = currentRankingService.getAndIncrement() % rankingServices.size
    var servicesPinged = 1
    var requestSuccessful = false
    var response: Pair<Boolean, HttpResponse?>
    var resp: HttpResponse
    while (servicesPinged <= rankingServices.size  && !requestSuccessful){
        response = sendRankingRequest("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/bulkUprank", body, 1 )
        if (response.first){
            resp = response.second!!
            requestSuccessful = true
            return Pair(true, resp)
        } else{
            servicesPinged++;
            cr += 1 % rankingServices.size
        }
    }
    return Pair(false, null)
}

suspend fun handleGameCreationRankingFail(body: String): Pair<Boolean, HttpResponse?>{
    var cr = currentRankingService.getAndIncrement() % rankingServices.size
    var servicesPinged = 1
    var requestSuccessful = false
    var response: Pair<Boolean, HttpResponse?>
    var resp: HttpResponse
    while (servicesPinged <= rankingServices.size  && !requestSuccessful){
        response = sendRankingRequest("http://${rankingServices[cr].address}:${rankingServices[cr].internal_port}/bulkDerank", body, 1 )
        if (response.first){
            resp = response.second!!
            requestSuccessful = true
            return Pair(true, resp)
        } else{
            servicesPinged++;
            cr += 1 % rankingServices.size
        }
    }
    return Pair(false, null)
}

suspend fun handleGameCreationGaming(body: String): Pair<Boolean, HttpResponse?>{
    var cr = currentGameService
    var servicesPinged = 1
    var candidateCR = gamingServices.keys().toList().toMutableList()
    var requestSuccessful = false
    var response: Pair<Boolean, HttpResponse?>
    var resp: HttpResponse
    while (servicesPinged <= gamingServices.size  && !requestSuccessful){
        response = sendGameRequest("http://${gamingServiceInfo[cr]!!.address}:${gamingServiceInfo[cr]!!.internal_port}/addGame", body, 1)
        if (response.first){
            resp = response.second!!
            requestSuccessful = true
            return Pair(true, resp)
        } else{
            servicesPinged++;
            candidateCR.remove(cr)
            cr =  candidateCR.random()
        }
    }
    return Pair(false, null)
}

suspend fun handleGameCreationGamingFail(body: String): Pair<Boolean, HttpResponse?>{
    var cr = currentGameService
    var servicesPinged = 1
    var candidateCR = gamingServices.keys().toList().toMutableList()
    var requestSuccessful = false
    var response: Pair<Boolean, HttpResponse?>
    var resp: HttpResponse
    while (servicesPinged <= gamingServices.size  && !requestSuccessful){
        response = sendGameRequest("http://${gamingServiceInfo[cr]!!.address}:${gamingServiceInfo[cr]!!.internal_port}/removeGame", body, 1)
        if (response.first){
            resp = response.second!!
            requestSuccessful = true
            return Pair(true, resp)
        } else{
            servicesPinged++;
            candidateCR.remove(cr)
            cr =  candidateCR.random()
        }
    }
    return Pair(false, null)
}