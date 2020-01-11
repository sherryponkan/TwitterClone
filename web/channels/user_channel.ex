defmodule TwitterClone.UsersChannel do
  use TwitterClone.Web, :channel
  alias TwitterClone.{User, Tweet, Hashtag, MentionedUser}
  alias TwitterClone.Endpoint


  def join("user:" <> user_id, _params, socket) do
    user_id = String.to_integer(user_id)
    IO.puts "socket pid???"
    IO.inspect self()
    user = User
    |> Repo.get(user_id)
    |> Repo.preload(:tweets)
    {:ok, %{tweets: user.tweets}, assign(socket, :user, user)}
  end



  def handle_in("user:add", %{"tweet" => tweet}, socket) do
    user = socket.assigns.user
    tweet = user.user_name <> ": " <>tweet

    changeset = user
    |> build_assoc(:tweets)
    |> Tweet.changeset(%{content: tweet})

    case Repo.insert(changeset) do
      {:ok, tweet} ->


        # try to find hash tag in the tweet, and if found, connect the tweet to that hashtag's id
        string_array = String.split(tweet.content, [" ", ", "])
        hashtags = Enum.filter(string_array, fn x ->(
          String.starts_with?(x, "#")
        )end)

        if !Enum.empty?(hashtags) do
          Enum.each(hashtags, fn tag ->(
            case Repo.get_by(Hashtag, tag: tag) do
              nil ->
                tweet_id = Integer.to_string(tweet.id)
                tweet_ids = [tweet_id]
                changeset = Hashtag.changeset(%Hashtag{}, %{"tag" => tag, "tweet_ids" => tweet_ids})
                case Repo.insert(changeset) do
                  {:ok, hashtag} ->
                    IO.inspect hashtag.tweet_ids
                  {:error, changeset} ->
                    IO.puts "oops, something went wrong"
                end
              hashtag ->
                tweet_id = Integer.to_string(tweet.id)
                tweet_list = hashtag.tweet_ids ++ [tweet_id]
                changeset = Hashtag.changeset(hashtag, %{"tweet_ids" => tweet_list})
                case Repo.update(changeset) do
                  {:ok, tag} ->
                    IO.inspect hashtag.tweet_ids
                  {:error, changeset} ->
                    IO.puts "oops, something went wrong"
                end
            end
          )end)
        end

        #mention-tweets

        string_array = String.split(tweet.content, [" ", ", "])
        IO.puts "++++++++++++++++++++++"
        IO.inspect string_array

        mentions = Enum.filter(string_array, fn x ->(
          String.starts_with?(x, "@")
        )end)

        IO.inspect mentions

        if !Enum.empty?(mentions) do
          Enum.each(mentions, fn mention ->(
            user_name = String.slice(mention, 1..-1)
            case Repo.get_by(User, user_name: user_name) do
              nil ->
                IO.puts "No such user exists"
              user ->
                case Repo.get_by(MentionedUser, user_id: user.id) do
                  nil ->
                    tweet_id = Integer.to_string(tweet.id)
                    tweet_ids = [tweet_id]
                    changeset = MentionedUser.changeset(%MentionedUser{}, %{"user_id" => user.id, "tweet_ids" => tweet_ids})
                    case Repo.insert(changeset) do
                      {:ok, user} ->
                        IO.inspect user.tweet_ids
                      {:error, changeset} ->
                        IO.puts "oops, something went wrong"
                    end
                  mentioned_user ->
                    tweet_id = Integer.to_string(tweet.id)
                    tweet_list = mentioned_user.tweet_ids ++ [tweet_id]
                    changeset = MentionedUser.changeset(mentioned_user, %{"tweet_ids" => tweet_list})
                    case Repo.update(changeset) do
                      {:ok, mentioned_user} ->
                        IO.inspect mentioned_user
                      {:error, changeset} ->
                        IO.puts "oops, something went wrong"
                    end
                end
            end
          )end)
        end


        ############
        follower_list = user.follower_ids
        Enum.each(follower_list, fn id ->(
          Endpoint.broadcast("user:"<>id, "user:add",  %{tweet: tweet})
        )end)
        broadcast!(socket, "user:add", %{tweet: tweet})
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{}}, socket}
    end

  end
end
