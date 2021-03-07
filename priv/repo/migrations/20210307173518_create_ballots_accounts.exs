defmodule Vote.Repo.Migrations.CreateBallotsAccounts do
  use Ecto.Migration

  def change do
    create table(:ballots_accounts) do
      add :ballot_id, references(:ballots)
      add :account_id, references(:accounts)
    end

    create unique_index(:ballots_accounts, [:ballot_id, :account_id])
  end
end
