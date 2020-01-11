defmodule TwitterClone.Router do
  use TwitterClone.Web, :router

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

  scope "/", TwitterClone do
    pipe_through :browser # Use the default browser stack

    get "/", UserController, :new
    resources "/users", UserController

    get "/users/new", UserController, :logout
    put "/users/:id/follow", UserController, :follow
    get "/users/:id/follow", UserController, :index
    get "/users/:id/following_list", UserController, :subscribes
    get "/users/:id/followers", UserController, :followers
    get "/users/:id/tweets", UserController, :showtweets
    resources "/tweets", TweetController
    resources "/searchs", SearchController
  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitterClone do
  #   pipe_through :api
  # end
end
