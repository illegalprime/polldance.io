defmodule VoteWeb.HomepageController do
  alias Vote.Accounts.Account
  use VoteWeb, :controller
  alias VoteWeb.Authentication

  @memes [
    "/images/bidenist.png",
    "/images/shapiro.jpg",
    "/images/bunny.jpg",
    "/images/liberal.jpg",
    "/images/llama.jpg",
    "/images/racoon.png",
  ]

  @account_cs Account.unverified_changeset(%Account{}, %{})

  def index(conn, _params) do
    if conn.assigns[:account] do
      redirect(conn, to: Routes.page_path(conn, :index))
    else
      splash = Routes.static_path(conn, Enum.random(@memes))
      render(conn, :index,
        splash: splash,
        login: Routes.auth_path(conn, :login),
        login_cs: Map.get(conn.assigns, :login_cs, @account_cs),
        register: Routes.auth_path(conn, :register),
        register_cs: Map.get(conn.assigns, :register_cs, @account_cs)
      )
    end
  end
end
