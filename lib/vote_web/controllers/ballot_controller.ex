defmodule VoteWeb.BallotController do
  alias Vote.Ballots
  alias Vote.Token
  use VoteWeb, :controller

  def show(conn, %{"ballot" => token}) do
    with {:ok, id} <- Token.verify_ballot_token(token) do
      ballot = Ballots.by_id(id)
      require Logger
      Logger.warn(inspect(ballot))
      render(conn, :show,
        ballot: ballot
      )
    else
      _ -> conn
      |> put_flash(:error, "Invalid or expired (100 days) ballot link.")
      |> redirect(to: Routes.homepage_path(conn, :index))
    end
  end
end
