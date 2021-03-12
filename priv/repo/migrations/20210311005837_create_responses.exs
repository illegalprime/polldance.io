defmodule Vote.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses) do
      add :response, :map
      add :type, :string
      add :ballot_id, references(:ballots, on_delete: :delete_all)
      add :account_id, references(:accounts, on_delete: :delete_all)
      add :ballot_item_id, references(:ballot_items, on_delete: :delete_all)

      timestamps()
    end

    create index(:responses, [:ballot_id])
    create index(:responses, [:account_id])
    create index(:responses, [:ballot_item_id])
    create unique_index(:responses, [:account_id, :ballot_id])
  end
end
