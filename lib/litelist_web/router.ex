defmodule LitelistWeb.Router do
  use LitelistWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Litelist.Auth.Pipeline
    plug :current_neighbor
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
    plug :current_neighbor
  end

  pipeline :current_neighbor do
    plug Litelist.Plugs.CurrentNeighbor
  end

  # Definitely logged in scope
  scope "/", LitelistWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/secret", PageController, :secret
    resources "/sales", ForSaleController, only: [:new, :create, :edit, :update, :delete]
    resources "/jobs", JobController, only: [:new, :create, :edit, :update, :delete]
    resources "/events", EventController, only: [:new, :create, :edit, :update, :delete]
    resources "/businesses", BusinessController, only: [:new, :create, :edit, :update, :delete]
    resources "/emergency_info", EmergencyInformationController, only: [:new, :create, :edit, :update, :delete]
    get "/dashboard", DashboardController, :index
    get "/dashboard/posts", DashboardController, :posts
    delete "/dashboard/posts", DashboardController, :delete_all
    delete "/dashboard/posts/delete/:id", DashboardController, :delete
    get "/dashboard/posts/export", DashboardController, :export_posts
  end

  scope "/", LitelistWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index
    get "/post2list", PageController, :information
    get "/neighbor-login", PageController, :neighbor_login
    post "/", PageController, :login
    post "/logout", PageController, :logout
    resources "/sales", ForSaleController, only: [:show, :index]
    resources "/jobs", JobController, only: [:show, :index]
    resources "/events", EventController, only: [:show, :index]
    resources "/businesses", BusinessController, only: [:show, :index]
    resources "/emergency_info", EmergencyInformationController, only: [:show, :index]
  end

  # Other scopes may use custom stacks.
  # scope "/api", LitelistWeb do
  #   pipe_through :api
  # end
end
