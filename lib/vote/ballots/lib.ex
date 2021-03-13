defmodule Vote.Ballots do
  import Ecto.Changeset
  import Ecto.Query
  alias Vote.Repo
  alias __MODULE__.{Ballot, BallotItem}

  def authored_by_user(user) do
    query = from b in Ballot,
      where: b.account_id == ^user.id,
      select: b,
      order_by: [desc: b.inserted_at]

    Repo.all(query)
  end

  def by_id(id) do
    query = from b in Ballot,
      where: b.id == ^id,
      select: b,
      preload: [
        ballot_items: ^from(
          item in BallotItem,
          order_by: [asc: item.id]
        )
      ]
    Repo.one(query)
  end

  def save(params, user) do
    build_ballot(params)
    |> put_assoc(:account, user)
    |> Repo.insert()
  end

  def new(parms \\ %{})

  def new(%{"ballot_items" => _} = params) do
    build_ballot(params) |> Map.put(:action, :insert)
  end

  def new(params) do
    build_ballot(params) |> push_item() |> Map.put(:action, :insert)
  end

  def build_ballot(params \\ %{}) do
    %Ballot{}
    |> Repo.preload([:ballot_items])
    |> Ballot.changeset(params)
  end

  def new_item(params \\ %{})

  def new_item(%{"options" => _} = params) do
    %BallotItem{}
    |> BallotItem.changeset(params)
  end

  def new_item(params) do
    new_item(Map.put(params, "options", [""]))
  end

  def get_items(cs) do
    Map.get(cs.changes, :ballot_items, cs.data.ballot_items)
  end

  def push_item(cs, params \\ %{}) do
    put_assoc(cs, :ballot_items, get_items(cs) ++ [new_item(params)])
  end

  def delete_item(cs, idx) do
    put_assoc(cs, :ballot_items, List.delete_at(get_items(cs), idx))
  end

  def get_options(cs) do
    Map.get(cs.changes, :options, cs.data.options) || []
  end

  def push_option(cs, idx) do
    items = get_items(cs)
    |> Enum.with_index()
    |> Enum.map(fn {item, i} ->
      case i == idx do
        false -> item
        true -> put_change(item, :options, get_options(item) ++ [""])
      end
    end)
    put_assoc(cs, :ballot_items, items)
  end

  def delete_option(cs, item_i, option_i) do
    items = get_items(cs)
    |> Enum.with_index()
    |> Enum.map(fn {item, i} ->
      case i == item_i do
        false -> item
        true ->
          new_options = List.delete_at(get_options(item), option_i)
          put_change(item, :options, new_options)
      end
    end)
    put_assoc(cs, :ballot_items, items)
  end
end
