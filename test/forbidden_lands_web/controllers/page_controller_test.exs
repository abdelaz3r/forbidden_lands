defmodule ForbiddenLandsWeb.PageControllerTest do
  use ForbiddenLandsWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Créer une nouvelle instance"
  end
end
