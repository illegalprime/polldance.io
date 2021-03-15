defmodule Vote.Repo.Migrations.AddBallotSlug do
  use Ecto.Migration

  def change do
    alter table(:ballots) do
      add :slug, :string
    end

    create unique_index(:ballots, [:slug])
  end
end
