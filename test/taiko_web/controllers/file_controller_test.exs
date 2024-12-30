defmodule TaikoWeb.FileControllerTest do
  use TaikoWeb.ConnCase

  import Taiko.XxxFixtures

  alias Taiko.Xxx.File

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all files", %{conn: conn} do
      conn = get(conn, ~p"/api/files")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create file" do
    test "renders file when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/files", file: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/files/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/files", file: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update file" do
    setup [:create_file]

    test "renders file when data is valid", %{conn: conn, file: %File{id: id} = file} do
      conn = put(conn, ~p"/api/files/#{file}", file: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/files/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, file: file} do
      conn = put(conn, ~p"/api/files/#{file}", file: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete file" do
    setup [:create_file]

    test "deletes chosen file", %{conn: conn, file: file} do
      conn = delete(conn, ~p"/api/files/#{file}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/files/#{file}")
      end
    end
  end

  defp create_file(_) do
    file = file_fixture()
    %{file: file}
  end
end
