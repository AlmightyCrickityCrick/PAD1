package com.unolive

import registrationResult

class ServiceRegistrationServer : ServiceRegistrationGrpcKt.ServiceRegistrationCoroutineImplBase() {
    override suspend fun addService(request: ServiceQueue.ServiceInstance): ServiceQueue.registrationResult {
        println("-----------------------------------------------------------")
        println("Received addService Request ${request.type} ${request.address} ${request.externalPort}")
        println("-----------------------------------------------------------")

        return registrationResult{ success = 1}
    }
    override suspend fun updateService(request: ServiceQueue.HealthUpdate): ServiceQueue.registrationResult {
        return registrationResult{ success = 1}
    }

    override suspend fun removeService(request: ServiceQueue.ServiceInstance): ServiceQueue.registrationResult {
        return registrationResult{ success = 1}
    }
}