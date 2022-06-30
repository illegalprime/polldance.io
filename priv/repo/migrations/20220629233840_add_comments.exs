defmodule Vote.Repo.Migrations.AddComments do
  use Ecto.Migration

  def change do
    alter table(:responses) do
      add :comments, :map
    end
  end
end
