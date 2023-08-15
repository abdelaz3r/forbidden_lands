defmodule ForbiddenLandsWeb.PageControllerTest do
  use ForbiddenLandsWeb.ConnCase

  test "GET /en", %{conn: conn} do
    conn = get(conn, ~p"/en")
    assert html_response(conn, 200) =~ "Active adventures"
  end
end
