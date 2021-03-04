defmodule VoteWeb.Authentication.Pipeline do
  import Plug.Conn
  use Guardian.Plug.Pipeline,
    otp_app: :vote,
    error_handler: VoteWeb.Authentication.ErrorHandler,
    module: VoteWeb.Authentication

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
  plug :attach_user

  def attach_user(conn, _opts) do
    account = VoteWeb.Authentication.get_current_account(conn)
    assign(conn, :account, account)
  end
end
