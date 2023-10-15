package com.service_discovery.unolive.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class HealthModel(val database: DatabaseState, val load: LoadState, val lobbies: Int?=null)

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