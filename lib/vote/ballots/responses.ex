defmodule Vote.Ballots.Responses do
  use Ecto.Schema
  import Ecto.Changeset

  schema "responses" do
    field :response, :map, default: %{}
    field :type, :string

    belongs_to :account, Vote.Accounts.Account
    belongs_to :ballot, Vote.Ballots.Ballot
    belongs_to :ballot_item, Vote.Ballots.BallotItem

    field :append, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(responses, attrs, account, ballot, ballot_item) do
    responses
    |> cast(attrs, [:response, :append])
    |> put_assoc(:account, account)
    |> put_assoc(:ballot, ballot)
    |> put_assoc(:ballot_item, ballot_item)
    |> put_change(:type, ballot_item.voting_method)
    |> validate_required([:type, :ballot, :ballot_item, :account])
  end
end
