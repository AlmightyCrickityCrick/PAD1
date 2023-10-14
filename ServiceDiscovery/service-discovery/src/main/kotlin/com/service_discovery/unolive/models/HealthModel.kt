package com.service_discovery.unolive.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class HealthModel(val database: DatabaseState, val load: LoadState)

@Serializable
enum class DatabaseState{
    @SerialName("none") none,
    @SerialName("ok") ok,
    @SerialName("disconnected") disconnected
}

@Serializable
enum class LoadState{
    @SerialName("ok") ok,
    @SerialName("full")full
}