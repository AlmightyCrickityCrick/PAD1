defmodule EtlOverseerTest do
  use ExUnit.Case
  doctest EtlOverseer

  test "greets the world" do
    assert EtlOverseer.hello() == :world
  end
end
