defmodule Vote.Ballots.Ballot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ballots" do
    field :close_date, :date
    field :close_time, :time
    field :desc, :string
    field :title, :string
    many_to_many :participants, Vote.Accounts.Account, join_through: "ballots_accounts"
    has_many :ballot_items, Vote.Ballots.BallotItem

    timestamps()
  end

  @doc false
  def changeset(ballot, attrs) do
    ballot
    |> cast(attrs, [:title, :desc, :close_time, :close_date])
    |> cast_assoc(:ballot_items, required: true)
    |> validate_required([:title, :desc, :close_time, :close_date])
    |> unique_constraint(:title)
  end
end
