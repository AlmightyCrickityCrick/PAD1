
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
@Serializable
data class RegisterModel(val type: ServiceType, var address: String? = null, val internal_port: Int? = null, val external_port: Int?=null)
@Serializable
enum  class ServiceType{
    @SerialName("game_service") game_service,
    @SerialName("ranking_service") ranking_service,
    @SerialName("gateway_service") gateway_service
}