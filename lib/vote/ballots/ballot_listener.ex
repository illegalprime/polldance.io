defmodule Vote.Ballots.BallotListener do
  use GenServer
  alias Phoenix.PubSub
  alias Vote.Repo
  alias Vote.Ballots.BallotItem

  #
  # Client
  #
  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: :"ballot/#{id}")
  end

  def topic(pid) do
    GenServer.call(pid, :topic)
  end

  #
  # Server
  #
  @impl true
  def init(id) do
    PubSub.subscribe(Vote.PubSub, "ballot/#{id}/listener")
    {:ok, id}
  end

  @impl true
  def handle_call(:topic, _from, id) do
    {:reply, topic(id), id}
  end

  @impl true
  def handle_info({:add_option, item_id, option}, id) do
    item = Repo.get(BallotItem, item_id)
    valid? = BallotItem.option_valid(item.options, option)

    if valid? and item.appendable do
      BallotItem.push_option_cs(item, option) |> Repo.update!()
      update(id)
    end

    {:noreply, id}
  end

  def update(id) do
    PubSub.broadcast(Vote.PubSub, "ballot/#{id}/update", :update)
  end
end
