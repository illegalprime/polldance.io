defmodule Vote.Ballots.Responses do
  use Ecto.Schema
  import Ecto.Changeset

  schema "responses" do
    field :response, :map, default: %{}
    field :comments, :map, default: %{}
    field :type, :string
    field :public_user, :string, default: nil

    belongs_to :account, Vote.Accounts.Account
    belongs_to :ballot, Vote.Ballots.Ballot
    belongs_to :ballot_item, Vote.Ballots.BallotItem

    field :append, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(responses, attrs, user, ballot_id, ballot_item) do
    responses
    |> cast(attrs, [:response, :append, :comments])
    |> put_change(:ballot_id, ballot_id)
    |> put_change(:ballot_item_id, ballot_item.id)
    |> put_change(:type, ballot_item.voting_method)
    |> add_account(user)
    |> validate_required([:type, :ballot_id, :ballot_item_id])
  end

  def add_account(cs, user) when is_binary(user) do
    cs
    |> put_change(:public_user, user)
    |> validate_required(:public_user)
  end

  def add_account(cs, account_id) do
    cs
    |> put_change(:account_id, account_id)
    |> validate_required(:account_id)
  end
end
