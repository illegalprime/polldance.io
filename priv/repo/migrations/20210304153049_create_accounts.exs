defmodule Vote.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :email, :string
      add :encrypted_password, :string
      add :verified, :boolean, default: false, null: false
      add :provider, :string

      timestamps()
    end

    create unique_index(:accounts, [:email])
  end
end
