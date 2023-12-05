defmodule UnoWarehouse.Repo.Migrations.CreateWarehouseTables do
  use Ecto.Migration

  def change do
    create table(:players_evo) do
      add :user_id, :integer, null: false
      add :rank, :integer, default: 1
      add :is_banned, :boolean, default: false
      add :time, :string
    end

    create table(:games) do
      add :lobby_number, :integer, null: false, unique: true
      add :time_started, :string
      add :time_ended, :string
      add :winner, :id
      add :players, {:array, :id}
    end

    create unique_index(:games, [:lobby_number])
  end
end
