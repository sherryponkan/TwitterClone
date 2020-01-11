defmodule TwitterClone.UserController do
  use TwitterClone.Web, :controller

  alias TwitterClone.User


  def index(conn, _params) do
    current_user = get_session(conn, :user_id)
    user = Repo.get(User, current_user)
    list = user.following_ids
    users = Repo.all(User)
    render(conn, "index.html", users: users, list: list, current_id: current_user)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user_params = user_params

    changeset = User.changeset(%User{}, user_params)
    # Map.put(changeset, :follower_ids, [])
    # Map.put(changeset, :following_ids, [])
    IO.inspect changeset

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> put_session(:user_id, user.id)
        |> assign(:current_user, user.id)
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def logout(conn) do
    conn
    |> delete_session(:user_id)
    |> assign(:current_user, nil)
    |> redirect(to: user_path(conn, :create))
  end

  def show(conn, %{"id" => id}) do  #liveview
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do

    user = Repo.get!(User, id)

    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def subscribes(conn, _params) do
    current_user = Repo.get(User, get_session(conn, :user_id))
    following_list = current_user.following_ids
    following_list = Enum.map(following_list, fn id -> (
      id = String.to_integer(id)
      Repo.get!(User, id)
    )end)
    # IO.inspect following_list
    render(conn, "following.html", users: following_list, current_user: current_user)
  end

  def followers(conn,_params) do
    current_user = Repo.get(User, get_session(conn, :user_id))
    follower_list = current_user.follower_ids
    follower_list = Enum.map(follower_list, fn id -> (
      id = String.to_integer(id)
      Repo.get!(User, id)
    )end)
    # IO.inspect following_list
    render(conn, "followers.html", users: follower_list, current_user: current_user)
  end

  def showtweets(conn, %{"id" => id}) do
    current_user = Repo.get(User, get_session(conn, :user_id))
    user = User
    |> Repo.get(id)
    |> Repo.preload(:tweets)
    render(conn, "querytweets.html", tweets: user.tweets, user: user, current_user: current_user)
  end

  def follow(conn, %{"id" => id}) do
    current_user = Repo.get(User, get_session(conn, :user_id))
    following_list = current_user.following_ids ++ [id]
    user = Repo.get!(User, id)
    user_id = Integer.to_string(current_user.id)
    follower_list = user.follower_ids ++ [user_id]
    # IO.puts "follower_list+++++++++++++++++++++++"
    # IO.inspect follower_list

    changeset = User.changeset(user, %{"follower_ids" => follower_list})
    IO.inspect changeset
    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Started following " <> user.user_name)
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end

    changeset = User.changeset(current_user, %{"following_ids" => following_list})

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end
