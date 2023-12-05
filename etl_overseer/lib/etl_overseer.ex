defmodule EtlOverseer do
  use Application

  def start(_type, _args) do
    children = [
      Players.Repo,
      Players.Repo.Replica1,
      Players.Repo.Replica2,
      GameHistory.Repo,
      UnoWarehouse.Repo,
      Supervisor.child_spec({EtlScheduler, []}, id: :etl_scheduler, restart: :permanent),
      Supervisor.child_spec({ReplicationOverseer, []}, id: :replication_overseer, restart: :permanent),
      Supervisor.child_spec({ReplicationSentinel, 0}, id: String.to_atom("rs0"), restart: :permanent),
      Supervisor.child_spec({ReplicationSentinel, 1}, id: String.to_atom("rs1"), restart: :permanent),
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
