defmodule VoteWeb.NewPollLive do
  use VoteWeb, :live_view
  import Ecto.Changeset
  import Logger
  alias Vote.Ballots

  def ok(socket), do: {:ok, socket}
  def noreply(socket), do: {:noreply, socket}

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(cs: Ballots.new())
    |> ok()
  end

  @impl true
  def handle_event("validate", %{"ballot" => ballot}, socket) do
    Logger.warn(inspect(ballot))
    socket
    |> assign(cs: Ballots.new(ballot))
    |> noreply()
  end

  @impl true
  def handle_event("push_ballot_item", _, socket) do
    socket
    |> assign(cs: Ballots.push_item(socket.assigns.cs))
    |> noreply()
  end

  def handle_event("delete_ballot_item", %{"idx" => idx}, socket) do
    socket
    |> assign(cs: Ballots.delete_item(socket.assigns.cs, String.to_integer(idx)))
    |> noreply()
  end

  def handle_event("push_option", %{"idx" => idx}, socket) do
    socket
    |> assign(cs: Ballots.push_option(socket.assigns.cs, String.to_integer(idx)))
    |> noreply()
  end

  def handle_event("delete_option", %{"idx" => idx, "item" => item}, socket) do
    idx = String.to_integer(idx)
    item = String.to_integer(item)

    socket
    |> assign(cs: Ballots.delete_option(socket.assigns.cs, item, idx))
    |> noreply()
  end

  def render_markdown(md), do: Vote.Markdown.render_markdown(md)
end
