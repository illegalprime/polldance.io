defmodule Vote.Repo.Migrations.AddBallotDrafts do
  use Ecto.Migration

  def change do
    alter table(:ballots) do
      add :draft, :boolean
    end
  end
end
