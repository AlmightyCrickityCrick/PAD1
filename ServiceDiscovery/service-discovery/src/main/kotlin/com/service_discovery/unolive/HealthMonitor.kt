package com.service_discovery.unolive

import RegisterModel
import com.service_discovery.unolive.models.DatabaseState
import com.service_discovery.unolive.models.HealthModel
import com.service_discovery.unolive.models.LoadState
import healthUpdate
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.serialization.json.Json
import java.util.concurrent.CyclicBarrier
import kotlin.concurrent.thread
import io.grpc.ManagedChannelBuilder
import serviceInstance

class HealthMonitor : Thread() {
    lateinit var bar: CyclicBarrier
    var client = HttpClient() {
        install(HttpTimeout) {
            requestTimeoutMillis = taskTimeoutLimitSeconds * 1000
        }
    }

    override fun run() {
        super.run()
        checkServices()
    }

    private fun checkServices(){
        bar = CyclicBarrier(registeredServices.size + 1)
        for (serv in registeredServices) thread {
            checkHealth(serv, 1)
        }
        bar.await()
        sleep(60000)
        checkServices()
    }

    private fun checkHealth(service: RegisterModel, attempt: Int) {
        println("Checking health of ${service.type} at ${service.address}")
        try {
            runBlocking {
                var job = launch {
                    var resp: HttpResponse = client.post("http://" + service.address + ":" + service.internal_port + "/getHealth")
                    var healthReport = Json.decodeFromString(HealthModel.serializer(), resp.body())
                    analyzeHealth(service, healthReport)
                }
            }
            bar.await()
        } catch (er: Exception) {
            if (attempt < 3) checkHealth(service, attempt + 1)
            else {
                handleCircuitBreak(service)
                bar.await()
            }
        }
    }

    private fun analyzeHealth(service: RegisterModel, healthReport: HealthModel){
        if (healthReport.load == LoadState.full){
            if (service !in busyServices) busyServices.add(service)
            runBlocking {
                launch{
                    deleteServiceFromGateway(service)
                }
            }
        } else if (healthReport.load == LoadState.ok && service in busyServices ){
            busyServices.remove(service)
            runBlocking {
                launch{
                    addServiceToGateway(service)
                }
            }
        } else if (healthReport.lobbies != null){
            runBlocking {
                launch{
                    notifyGatewayHealth(service.address!!, healthReport.lobbies)
                }
            }
        }
        if (healthReport.database == DatabaseState.disconnected){
            println("Service ${service.type} at address ${service.address} is disconnected from database!! Check the connection!")
        }
    }

    private suspend fun deleteServiceFromGateway(service: RegisterModel){
        val channel = ManagedChannelBuilder.forAddress(gateway.address, gateway.internal_port!!).usePlaintext().build()
        val stub = ServiceRegistrationGrpcKt.ServiceRegistrationCoroutineStub(channel)
        val data =  serviceInstance {
            type = service.type.name
            address = service.address!!
            internalPort = service.internal_port!!
            externalPort = service.external_port?:-1
        }
        val result = stub.removeService(data)
        print("Success is ${result.success}")
    }
    private suspend fun notifyGatewayHealth(sAddress: String, sLoad: Int){
        val channel = ManagedChannelBuilder.forAddress(gateway.address, gateway.internal_port!!).usePlaintext().build()
        val stub = ServiceRegistrationGrpcKt.ServiceRegistrationCoroutineStub(channel)
        val data =  healthUpdate {
            address = sAddress
            load = sLoad
        }
        val result = stub.updateService(data)
        print("Success is ${result.success}")
    }

    private fun handleCircuitBreak(service: RegisterModel){
        println("Service ${service.type} at address ${service.address} is unresponsive. Initiating break")
        if (service.type != gateway.type){
            runBlocking {
                launch{
                    deleteServiceFromGateway(service)
                }
            }
        }
        registeredServices.remove(service)
        restartService()
    }

    private fun restartService(){
        //TODO: Add call to API to restart the service
    }
}

suspend fun addServiceToGateway(service: RegisterModel){
    val channel = ManagedChannelBuilder.forAddress(gateway.address, gateway.internal_port!!).usePlaintext().build()
    val stub = ServiceRegistrationGrpcKt.ServiceRegistrationCoroutineStub(channel)
    val data =  serviceInstance {
        type = service.type.name
        address = service.address!!
        internalPort = service.internal_port!!
        externalPort = service.external_port?:-1
    }
    val result = stub.addService(data)
    print("Success is ${result.success}")
}