defmodule AnnaWeb.PageController do
  use AnnaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
