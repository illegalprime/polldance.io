defmodule Vote.Repo.Migrations.AddBallotClose do
  use Ecto.Migration

  def change do
    alter table(:ballots) do
      add :closed, :boolean, default: false, null: false
      add :live, :boolean, default: true, null: false
    end
  end
end
