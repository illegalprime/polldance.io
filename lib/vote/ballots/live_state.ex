defmodule Vote.Ballots.LiveState do
  use GenServer
  alias Vote.Ballots.{BallotListener, Supervisor}

  #
  # Client
  #
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def register(ballot_id) do
    GenServer.call(__MODULE__, {:register, ballot_id})
  end

  def ps() do
    GenServer.call(__MODULE__, :ps)
  end

  #
  # Server
  #
  @impl true
  def init(:ok) do
    registry = %{}
    refs = %{}
    {:ok, {registry, refs}}
  end

  @impl true
  def handle_call({:register, id}, {from, _tag}, {registry, refs}) do
    ref = Process.monitor(from)
    refs = Map.put(refs, ref, id)

    {references, pid} =
      case Map.get(registry, id) do
        # this id hasn't been seen yet, start it
        nil -> {MapSet.new([ref]), start_child(id)}
        # this started already, but count the reference
        {references, pid} -> {MapSet.put(references, ref), pid}
      end
    registry = Map.put(registry, id, {references, pid})

    {:reply, pid, {registry, refs}}
  end

  @impl true
  def handle_call(:ps, _from, {registry, refs}) do
    {:reply, {registry, refs}, {registry, refs}}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {registry, refs}) do
    {id, refs} = Map.pop(refs, ref)
    {references, pid} = Map.get(registry, id)
    references = MapSet.delete(references, ref)

    registry =
      case MapSet.size(references) do
        0 ->
          terminate_child(pid)
          Map.delete(registry, id)
        _ ->
          Map.put(registry, id, {references, pid})
      end

    {:noreply, {registry, refs}}
  end

  def start_child(id) do
    {:ok, pid} = DynamicSupervisor.start_child(Supervisor, {BallotListener, id})
    pid
  end

  def terminate_child(pid) do
    DynamicSupervisor.terminate_child(Supervisor, pid)
  end
end
