defmodule Vote.Repo.Migrations.PublicResponses do
  use Ecto.Migration

  def change do
    alter table(:responses) do
      add :public_user, :string
    end

    create index(:responses, [:public_user])
    create unique_index(:responses, [:public_user, :ballot_item_id])
  end
end
