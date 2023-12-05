defmodule DatabaseTracker do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do

    {:ok, %{repo: Players.Repo, replicas: [ Players.Repo.Replica1, Players.Repo.Replica2]}}
  end

  def handle_call({:repo}, _from, state) do
    {:reply, Map.get(state, :repo), state}
  end

  def handle_call({:replica}, _from, state) do
    {:reply, Enum.at(Map.get(state, :replicas), 0), state}
  end

  def handle_cast({:change_repo, new_info}, state) do
    new_state = case new_info["repo"] do
      0 -> %{repo: Players.Repo, replicas: [ Players.Repo.Replica1, Players.Repo.Replica2,]}
      1 -> %{repo: Players.Repo.Replica1, replicas: [ Players.Repo, Players.Repo.Replica2,]}
      2 -> %{repo: Players.Repo.Replica2, replicas: [ Players.Repo, Players.Repo.Replica1,]}
    end
    {:noreply, new_state}
  end
end
