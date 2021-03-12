defmodule Vote.Ballots.ResponseSet do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Vote.Repo
  alias Vote.Ballots.BallotItem
  alias Vote.Ballots.Responses

  embedded_schema do
    embeds_many :responses, Vote.Ballots.Responses
    embeds_one :ballot, Vote.Ballots.Ballot
  end

  # TODO: review this, does it make sense?
  def changeset(response_set, attrs, ballot, account) do
    require Logger

    by_id = response_set.responses
    |> Enum.map(fn r -> {r.ballot_item.id, r} end)
    |> Map.new()

    changesets = ballot.ballot_items
    |> Enum.with_index()
    |> Enum.map(fn {item, idx} ->
      resp = Map.get(by_id, item.id, %Responses{})
      attrs = get_responses(attrs["responses"], idx)
      Responses.changeset(resp, attrs, account, ballot, item)
    end)

    %ResponseSet{ballot: ballot}
    |> change()
    |> put_embed(:responses, changesets)
  end

  def update_item(cs, item_id) do
    new_responses = cs
    |> get_change(:responses)
    |> Enum.map(fn change ->
      case get_change(change, :ballot_item).data.id do
        ^item_id ->
          new_ballot = Repo.get(BallotItem, item_id)
          put_change(change, :ballot_item, new_ballot)
        _ -> change
      end
    end)
    put_embed(cs, :responses, new_responses)
  end

  def get_responses(nil, _idx), do: %{}
  def get_responses(params, idx) do
    convert_responses(Map.get(params, "#{idx}"))
  end

  def convert_responses(nil), do: %{}
  def convert_responses(%{"response" => items} = params) when is_list(items) do
    items
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new()
    |> (fn r -> %{ params | "response" => r } end).()
  end
  def convert_responses(%{"response" => items} = params) when is_map(items) do
    items
    |> Map.to_list()
    |> Enum.map(fn {k, v} -> {to_int(k), to_int(v)} end)
    |> Map.new()
    |> (fn r -> %{ params | "response" => r } end).()
  end
  def convert_responses(%{"response" => item} = params) when is_binary(item) do
    %{ params | "response" => %{to_int(item) => 1} }
  end
  def convert_responses(other), do: other

  def to_int("true"), do: 1
  def to_int("false"), do: 0
  def to_int(str), do: String.to_integer(str)
end
