defmodule RedisCache do
  use Nebulex.Cache,
    otp_app: :game_service,
    adapter: NebulexRedisAdapter

  end
