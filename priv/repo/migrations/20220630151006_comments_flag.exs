defmodule Vote.Repo.Migrations.CommentsFlag do
  use Ecto.Migration

  def change do
    alter table(:ballot_items) do
      add :comments, :boolean, default: false, null: false
    end
  end
end
