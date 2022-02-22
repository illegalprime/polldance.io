defmodule Vote.Ballots.Ballot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ballots" do
    # the ballot's title
    field :title, :string
    # a markdown description of the entire ballot
    field :desc, :string
    # the short-url used to access the ballot
    field :slug, :string
    # if the ballot is published or not
    field :draft, :boolean, default: true
    # if the ballot allows non-logged in users to vote
    field :public, :boolean, default: false
    # whether to allow more votes to be cast
    field :closed, :boolean, default: false
    # results are only shown after voting is closed
    field :live, :boolean, default: true
    # the questions posed in each ballot
    has_many :ballot_items, Vote.Ballots.BallotItem, on_replace: :delete
    # the author of the ballot
    belongs_to :account, Vote.Accounts.Account

    timestamps()
  end

  @doc false
  def changeset(ballot, attrs) do
    ballot
    |> cast(attrs, [:title, :desc, :public])
    |> cast_assoc(:ballot_items, required: true)
    |> validate_required([:title])
    |> unique_constraint(:title)
  end

  def update_slug(cs) do
    case get_field(cs, :slug, nil) do
      nil ->
        cs
        |> put_change(:slug, Nanoid.generate())
        |> validate_required(:slug)
      _cs -> cs
    end
  end
end
