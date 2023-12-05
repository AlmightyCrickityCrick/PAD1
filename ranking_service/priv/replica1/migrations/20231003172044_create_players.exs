defmodule Players.Repo.Replica1.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :username, :string, null: false, unique: true
      add :password, :string, null: false
      add :email, :string, null: false, unique: true
      add :rank, :integer, default: 1
      add :is_banned, :boolean, default: false
    end

    create unique_index(:players, [:username])
    create unique_index(:players, [:email])
  end
end
