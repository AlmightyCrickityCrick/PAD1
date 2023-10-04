defmodule GameServiceTest do
  use ExUnit.Case
  doctest GameService

  test "greets the world" do
    assert GameService.hello() == :world
  end
end
