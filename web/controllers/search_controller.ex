defmodule TwitterClone.SearchController do
  use TwitterClone.Web, :controller

  alias TwitterClone.{Search, Hashtag, User, Tweet, MentionedUser}

  def index(conn, _params) do
    searchs = Repo.all(Search)
    render(conn, "index.html", searchs: searchs)
  end

  def new(conn, _params) do
    current_user = Repo.get(User, get_session(conn, :user_id))
    changeset = Search.changeset(%Search{})
    render(conn, "new.html", current_user: current_user, changeset: changeset)
  end

  def create(conn, %{"search" => search_params}) do
    current_user = Repo.get(User, get_session(conn, :user_id))
    changeset = Search.changeset(%Search{}, search_params)
    case Repo.insert(changeset) do
      {:ok, search} ->
        content = search.content
        if String.contains?(content, "#") do
          case Repo.get_by(Hashtag, tag: content) do
            nil ->
              conn
              |> put_flash(:info, "No such hashtag exist")
              changeset = Search.changeset(%Search{})
              render(conn, "new.html", current_user: current_user, changeset: changeset)
            tag ->
              tweet_ids = tag.tweet_ids
              tweet_list = Enum.map(tweet_ids, fn id -> (
                id = String.to_integer(id)
                Repo.get(Tweet, id)
              )end)

              render(conn, "show.html", current_user: current_user, tweets: tweet_list, search: search)
          end
        end

        if String.contains?(content, "@") do
          user_name = String.slice(content, 1..-1)
          case Repo.get_by(User, user_name: user_name) do
            nil ->
              conn
              |> put_flash(:info, "No such user exist")
              changeset = Search.changeset(%Search{})
              render(conn, "new.html", current_user: current_user, changeset: changeset)
            user ->
              id = user.id
              case Repo.get_by(MentionedUser, user_id: id) do
                nil ->
                  conn
                  |> put_flash(:info, "No one mentioned this user")
                  changeset = Search.changeset(%Search{})
                  render(conn, "new.html", current_user: current_user, changeset: changeset)
                mentioned_user ->
                  tweet_ids = mentioned_user.tweet_ids
                  tweet_list = Enum.map(tweet_ids, fn id -> (
                    id = String.to_integer(id)
                    Repo.get!(Tweet, id)
                  )end)

                  render(conn, "show.html", current_user: current_user, tweets: tweet_list, search: search)
              end
          end
        end

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    search = Repo.get!(Search, id)
    render(conn, "show.html", search: search)
  end

  def edit(conn, %{"id" => id}) do
    search = Repo.get!(Search, id)
    changeset = Search.changeset(search)
    render(conn, "edit.html", search: search, changeset: changeset)
  end

  def update(conn, %{"id" => id, "search" => search_params}) do
    search = Repo.get!(Search, id)
    changeset = Search.changeset(search, search_params)

    case Repo.update(changeset) do
      {:ok, search} ->
        conn
        |> put_flash(:info, "Search updated successfully.")
        |> redirect(to: search_path(conn, :show, search))
      {:error, changeset} ->
        render(conn, "edit.html", search: search, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    search = Repo.get!(Search, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(search)

    conn
    |> put_flash(:info, "Search deleted successfully.")
    |> redirect(to: search_path(conn, :index))
  end
end
