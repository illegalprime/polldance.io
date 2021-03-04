defmodule VoteWeb.HomepageController do
  use VoteWeb, :controller

  @memes [
    "/images/bidenist.png",
    "/images/shapiro.jpg",
  ]

  def index(conn, _params) do
    splash = Routes.static_path(conn, Enum.random(@memes))
    render(conn, :index, splash: splash)
  end
end
