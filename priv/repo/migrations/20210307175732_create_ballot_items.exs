defmodule Vote.Repo.Migrations.CreateBallotItems do
  use Ecto.Migration

  def change do
    create table(:ballot_items) do
      add :title, :string
      add :desc, :text
      add :options, {:array, :text}
      add :voting_method, :string
      add :appendable, :boolean, default: false, null: false
      add :ballot, references(:ballots, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:ballot_items, [:title, :ballot])
    create index(:ballot_items, [:ballot])
  end
end
