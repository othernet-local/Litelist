defmodule LitelistWeb.FlagControllerTest do
  use LitelistWeb.ConnCase
  import Phoenix.Controller

  alias Litelist.Factory
  alias Litelist.Auth.Guardian

  alias LitelistWeb.Router.Helpers, as: Routes

  @create_attrs %{admin_response: "some admin_response", description: "some description", type: ["Incorrect information"]}
  @update_attrs %{admin_response: "some updated admin_response", description: "some updated description", status: "post_restored"}
  @invalid_attrs %{admin_response: nil, description: nil, status: nil, type: nil}

  describe "index" do
    test "Renders 401 if not logged in", %{conn: conn} do
      conn = conn
        |> get(Routes.flag_path(conn, :index))

      assert response(conn, 401)
    end

    test "Renders 401 if logged in but not admin", %{conn: conn} do
      neighbor = Factory.insert(:neighbor)
      conn = conn
        |> login_neighbor(neighbor)
        |> get(Routes.flag_path(conn, :index))

      assert response(conn, 401)
    end

    test "lists all flags", %{conn: conn} do
      admin = Factory.insert(:admin)
      conn = conn
        |> login_neighbor(admin)
        |> get(Routes.flag_path(conn, :index))

      assert html_response(conn, 200)
      assert view_template(conn) == "index.html"
    end
  end

  describe "show" do
    test "shows a flag if the type matches", %{conn: conn} do
      flag = Factory.insert(:flag)
      conn = conn
        |> get(Routes.flag_path(conn, :show, flag))

      assert html_response(conn, 200)
      assert view_template(conn) == "show.html"
    end
  end

  describe "new flag" do
    test "renders form", %{conn: conn} do
      post = Factory.insert(:job)
      conn = conn
        |> get(Routes.flag_path(conn, :new, %{post_id: post}))
      
      assert html_response(conn, 200)
      assert view_template(conn) == "new.html"
    end

    test "redirects without post_id param", %{conn: conn} do
      conn = conn
        |> get(Routes.flag_path(conn, :new))
      
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end
  
  describe "create flag" do
    test "redirects to show when data is valid", %{conn: conn} do
      neighbor = Factory.insert(:neighbor)
      post = Factory.insert(:job, %{neighbor_id: neighbor.id})
      attrs = Map.merge(@create_attrs, %{post_id: post.id})
      conn = conn
        |> login_neighbor(neighbor)
        |> post(Routes.flag_path(conn, :create), flag: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.flag_path(conn, :show, id)

      conn = conn
        |> recycle()
        |> login_neighbor(neighbor)

      conn = get conn, Routes.flag_path(conn, :show, id)
      assert html_response(conn, 200)
      assert view_template(conn) == "show.html"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      neighbor = Factory.insert(:neighbor)
      post = Factory.insert(:job, %{neighbor_id: neighbor.id})
      attrs = Map.merge(@invalid_attrs, %{post_id: post.id})
      conn = conn
        |> login_neighbor(neighbor)
        |> post(Routes.flag_path(conn, :create), flag: attrs)
      assert html_response(conn, 200)
      assert view_template(conn) == "new.html"
    end

    test "allows creation of flag even if not logged in", %{conn: conn} do
      post = Factory.insert(:job)
      attrs = Map.merge(@create_attrs, %{post_id: post.id})

      conn = conn
        |> post(Routes.flag_path(conn, :create), flag: attrs)
     
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.flag_path(conn, :show, id)

      conn = conn
        |> recycle()

      conn = get conn, Routes.flag_path(conn, :show, id)
      assert html_response(conn, 200)
      assert view_template(conn) == "show.html"
    end
  end

  describe "edit flag" do
    test "renders 401 for editing chosen flag even if created by logged in neighbor", %{conn: conn} do
      neighbor = Factory.insert(:neighbor)
      flag = Factory.insert(:flag, %{neighbor_id: neighbor.id})

      conn = conn
        |> login_neighbor(neighbor)
        |> get(Routes.flag_path(conn, :edit, flag))
      assert response(conn, 401)
    end

    test "renders form for editing chosen flag if admin", %{conn: conn} do
      admin = Factory.insert(:admin)
      flag = Factory.insert(:flag)

      conn = conn
        |> login_neighbor(admin)
        |> get(Routes.flag_path(conn, :edit, flag))
      assert html_response(conn, 200)
      assert view_template(conn) == "edit.html"
    end

    test "redirects to index if flag was not created by the neighbor", %{conn: conn} do
      neighbor = Factory.insert(:neighbor)
      not_my_flag = Factory.insert(:flag)

      conn = conn
        |> login_neighbor(neighbor)
        |> get(Routes.flag_path(conn, :edit, not_my_flag))
        assert response(conn, 401)
    end

    test "unautorized 401 redirect if not logged in", %{conn: conn} do
      flag = Factory.insert(:flag)

      conn = conn
        |> get(Routes.flag_path(conn, :edit, flag))
      
      assert response(conn, 401)
    end
  end

  describe "update flag" do

    test "401 when data is valid but neighbor is not an admin", %{conn: conn} do
      neighbor = Factory.insert(:neighbor)
      flag = Factory.insert(:flag, %{neighbor_id: neighbor.id})

      conn = conn
        |> login_neighbor(neighbor)
        |> put(Routes.flag_path(conn, :update, flag), flag: @update_attrs)

      assert response(conn, 401)
    end

    test "redirects when data is valid as an admin", %{conn: conn} do
      admin = Factory.insert(:admin)
      flag = Factory.insert(:flag)

      conn = conn
        |> login_neighbor(admin)
        |> put(Routes.flag_path(conn, :update, flag), flag: @update_attrs)

      assert redirected_to(conn) == Routes.flag_path(conn, :show, flag)

      conn = conn
        |> recycle()
        |> login_neighbor(admin)

      conn = get conn, Routes.flag_path(conn, :show, flag)
      assert html_response(conn, 200)
      assert view_template(conn) == "show.html"
    end

    test "renders 401 when data is invalid and user is not an admin", %{conn: conn} do
      neighbor = Factory.insert(:neighbor)
      flag = Factory.insert(:flag, %{neighbor_id: neighbor.id})

      conn = conn
        |> login_neighbor(neighbor)
        |> put(Routes.flag_path(conn, :update, flag), flag: @invalid_attrs)

      assert response(conn, 401)
    end

    test "401 if flag was not created by the neighbor and neighbor is not admin", %{conn: conn} do
      neighbor = Factory.insert(:neighbor)
      not_my_flag = Factory.insert(:flag)

      conn = conn
        |> login_neighbor(neighbor)
        |> put(Routes.flag_path(conn, :update, not_my_flag), flag: @invalid_attrs)

      assert response(conn, 401)
    end

    test "unautorized 401 redirect if not logged in", %{conn: conn} do
      flag = Factory.insert(:flag)
      conn = conn
        |> put(Routes.flag_path(conn, :update, flag), flag: @invalid_attrs)

      assert response(conn, 401)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      admin = Factory.insert(:admin)
      post = Factory.insert(:job, %{neighbor_id: admin.id})
      flag = Factory.insert(:flag, %{post_id: post.id})
      conn = conn
        |> login_neighbor(admin)
        |> put(Routes.flag_path(conn, :update, flag), flag: @invalid_attrs)

      assert html_response(conn, 200)
      assert view_template(conn) == "edit.html"
    end
  end

  describe "delete flag" do

    test "401 on delete if neighbor is not admin", %{conn: conn} do
      neighbor = Factory.insert(:neighbor)
      flag = Factory.insert(:flag, %{neighbor_id: neighbor.id})

      conn = conn
        |> login_neighbor(neighbor)
        |> delete(Routes.flag_path(conn, :delete, flag))

        assert response(conn, 401)
    end

    test "deletes chosen flag as an admin", %{conn: conn} do
      admin = Factory.insert(:admin)
      flag = Factory.insert(:flag)

      conn = conn
        |> login_neighbor(admin)
        |> delete(Routes.flag_path(conn, :delete, flag))

      assert redirected_to(conn) == Routes.flag_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, Routes.flag_path(conn, :show, flag)
      end
    end

    test "unautorized 401 redirect if not logged in", %{conn: conn} do
      flag = Factory.insert(:flag)

      conn = conn
        |> delete(Routes.flag_path(conn, :delete, flag))

      assert response(conn, 401)
    end
  end

  defp login_neighbor(conn, neighbor) do
    {:ok, token, _} = Guardian.encode_and_sign(neighbor, %{}, token_type: :access)
    conn
      |> put_req_header("authorization", "bearer: " <> token)
  end
end
