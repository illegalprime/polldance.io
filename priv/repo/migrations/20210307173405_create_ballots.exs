defmodule Vote.Repo.Migrations.CreateBallots do
  use Ecto.Migration

  def change do
    create table(:ballots) do
      add :title, :string
      add :desc, :text
      add :public, :boolean, default: true, null: false
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:ballots, [:title])
    create index(:ballots, [:account_id])
  end
end
