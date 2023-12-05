defmodule Players.Repo.Replica1.Migrations.CreateFriends do
  use Ecto.Migration

  def change do
    create table(:friends) do
      add :user_id, references(:players)
      add :friend_id, references(:players)
      timestamps()
    end

  end
end
