defmodule GameHistory.Repo.Migrations.CreateHistory do
  use Ecto.Migration

  def change do
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
