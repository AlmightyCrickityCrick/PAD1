defmodule RankingServiceTest do
  use ExUnit.Case
  doctest RankingService

  test "greets the world" do
    assert RankingService.hello() == :world
  end
end
