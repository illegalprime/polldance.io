defmodule Vote.Repo.Migrations.BallotDefaultPrivate do
  use Ecto.Migration

  def change do
    alter table(:ballots) do
      modify :public, :boolean, default: false, null: false
    end
  end
end
