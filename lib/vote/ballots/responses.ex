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
  def changeset(responses, attrs, account_id, ballot_id, ballot_item) do
    responses
    |> cast(attrs, [:response, :append])
    |> put_change(:account_id, account_id)
    |> put_change(:ballot_id, ballot_id)
    |> put_change(:ballot_item_id, ballot_item.id)
    |> put_change(:type, ballot_item.voting_method)
    |> validate_required([:type, :ballot_id, :ballot_item_id, :account_id])
  end
end
