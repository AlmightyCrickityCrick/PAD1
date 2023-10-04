defmodule GameLobbySupervisor do
  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Process.flag(:trap_exit, true)
    IO.puts("---- GameLobbySupervisor Started ----")
    DynamicSupervisor.init(strategy: :one_for_one)
  end


end
