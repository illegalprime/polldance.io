defmodule VoteWeb.Views.Util do
  alias Vote.Token

  def ok(socket), do: {:ok, socket}
  def noreply(socket), do: {:noreply, socket}

  def ballot_token(ballot) do
    Token.gen_ballot_token(ballot)
  end
end
