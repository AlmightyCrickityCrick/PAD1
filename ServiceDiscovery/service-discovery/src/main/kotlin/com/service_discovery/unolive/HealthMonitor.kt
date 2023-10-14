package com.service_discovery.unolive

import RegisterModel
import com.service_discovery.unolive.models.DatabaseState
import com.service_discovery.unolive.models.HealthModel
import com.service_discovery.unolive.models.LoadState
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
            //TODO: Send to gateway to stop sending to service
        } else if (healthReport.load == LoadState.ok && service in busyServices ){
            busyServices.remove(service)
            //TODO: Send to Gateway to reinstate the service
        }
        if (healthReport.database == DatabaseState.disconnected){
            println("Service ${service.type} at address ${service.address} is disconnected from database!! Check the connection!")
        }
    }

    private fun handleCircuitBreak(service: RegisterModel){
        println("Service ${service.type} at address ${service.address} is unresponsive. Initiating break")
        if (service.type != gateway.type){
            //TODO: Send message by gRPC to erase service from gateway
        }
        registeredServices.remove(service)
        restartService()
    }

    private fun restartService(){

    }
}