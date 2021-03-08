defmodule Vote.Repo.Migrations.CreateBallotItems do
  use Ecto.Migration

  def change do
    create table(:ballot_items) do
      add :title, :string
      add :desc, :text
      add :options, {:array, :text}
      add :voting_method, :string
      add :appendable, :boolean, default: false, null: false
      add :ballot_id, references(:ballots, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:ballot_items, [:title, :ballot_id])
    create index(:ballot_items, [:ballot_id])
  end
end
