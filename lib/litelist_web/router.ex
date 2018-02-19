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
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end


  # Definitely logged in scope
  scope "/", LitelistWeb do
    pipe_through [:browser, :auth, :ensure_auth]
    get "/secret", PageController, :secret
    resources "/sales", ForSaleController, only: [:new, :create, :edit, :update, :delete]
  end
  
  scope "/", LitelistWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index
    post "/", PageController, :login
    post "/logout", PageController, :logout
    resources "/sales", ForSaleController, only: [:index, :show]
  end


  # Other scopes may use custom stacks.
  # scope "/api", LitelistWeb do
  #   pipe_through :api
  # end
end
