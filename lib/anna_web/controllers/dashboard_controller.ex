defmodule AnnaWeb.DashboardController do
  use AnnaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", layout: false)
  end
end
