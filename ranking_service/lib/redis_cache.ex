defmodule RedisCache do
use Nebulex.Cache,
  otp_app: :ranking_service,
  adapter: NebulexRedisAdapter

end
