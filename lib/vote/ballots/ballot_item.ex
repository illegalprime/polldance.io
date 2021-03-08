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
    |> cast(attrs, [:title, :desc, :voting_method, :appendable])
    |> put_options(Map.get(attrs, "options") || attrs[:options])
    |> validate_required([:title, :options, :voting_method, :appendable])
    |> unique_constraint(:title)
  end

  defp put_options(cs, options) do
    # remove any leading empty options (based on array_input implementation)
    options = options
    |> Enum.reverse()
    |> Enum.map(&String.trim/1)
    |> Enum.drop_while(&bad_option_value/1)
    |> Enum.reverse()

    # check if there are empty options in the middle
    empty_err = "cannot contain an empty option in the middle / at the start"
    has_empty? = Enum.any?(options, &bad_option_value/1)

    # if others can't add options then an option minimum is required
    appendable? = current_value(cs, :appendable)
    # check if there's at least two options to vote on
    len_err = "must have at least two options"
    has_two? = length(options) >= 2

    cs
    |> do_if(has_empty?, &(add_error(&1, :options, empty_err)))
    |> do_if(!appendable? && !has_two?, &(add_error(&1, :options, len_err)))
    |> put_change(:options, options)
  end

  defp bad_option_value(v), do: v == ""

  def current_value(cs, key) do
    Map.get(cs.changes, key, Map.get(cs.data, key))
  end

  def do_if(obj, pred, f) do
    case pred do
      true -> f.(obj)
      false -> obj
    end
  end
end
