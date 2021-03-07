defmodule Vote.Ballots.BallotItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ballot_items" do
    field :appendable, :boolean, default: false
    field :desc, :string
    field :options, {:array, :string}
    field :title, :string
    field :voting_method, :string
    belongs_to :ballot, Vote.Ballots.Ballot

    timestamps()
  end

  @doc false
  def changeset(ballot_item, attrs) do
    ballot_item
    |> cast(attrs, [:title, :desc, :options, :voting_method, :appendable])
    |> validate_required([:title, :desc, :options, :voting_method, :appendable])
    |> unique_constraint(:title)
  end
end
