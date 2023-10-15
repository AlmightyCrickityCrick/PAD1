package com.unolive

import RegisterModel
import registrationResult

class ServiceRegistrationServer : ServiceRegistrationGrpcKt.ServiceRegistrationCoroutineImplBase() {
    override suspend fun addService(request: ServiceQueue.ServiceInstance): ServiceQueue.registrationResult {
        println("-----------------------------------------------------------")
        println("Received addService Request ${request.type} ${request.address} ${request.externalPort}")
        println("-----------------------------------------------------------")
        if (request.type == "game_service"){
            gamingServiceInfo[request.address] = RegisterModel(
                ServiceType.game_service,
                request.address,
                request.internalPort,
                request.externalPort)
            gamingServices[request.address] = 0
            if (currentGameService == "") currentGameService = request.address
        } else{
            rankingServices.add(RegisterModel(
                ServiceType.game_service,
                request.address,
                request.internalPort))

        }
        return registrationResult{ success = 1}
    }
    override suspend fun updateService(request: ServiceQueue.HealthUpdate): ServiceQueue.registrationResult {
        println("-----------------------------------------------------------")
        println("Received update Request  ${request.address} ${request.load}")
        println("-----------------------------------------------------------")
        gamingServices[request.address] = request.load
        if (request.load < gamingServices[currentGameService]!!)
            currentGameService = request.address
        return registrationResult{ success = 1}
    }

    //TODO: Handle removeService and requests when all services are full
    override suspend fun removeService(request: ServiceQueue.ServiceInstance): ServiceQueue.registrationResult {
        println("-----------------------------------------------------------")
        println("Received remove Request ${request.type} ${request.address} ${request.externalPort}")
        println("-----------------------------------------------------------")
        if (request.type == "game_service"){
            gamingServices.remove(request.address)
            gamingServiceInfo.remove(request.address)
        } else{
            for (i in rankingServices){
                if (i.address == request.address) {
                    rankingServices.remove(i)
                    break;
                }
            }
        }

            return registrationResult{ success = 1}
    }
}