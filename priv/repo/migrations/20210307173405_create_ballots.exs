defmodule Vote.Repo.Migrations.CreateBallots do
  use Ecto.Migration

  def change do
    create table(:ballots) do
      add :title, :string
      add :desc, :text
      add :close_time, :time
      add :close_date, :date

      timestamps()
    end

    create unique_index(:ballots, [:title])
  end
end
