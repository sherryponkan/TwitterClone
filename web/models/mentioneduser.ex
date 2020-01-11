defmodule TwitterClone.MentionedUser do
  use TwitterClone.Web, :model

  schema "mentioned_users" do
    field :user_id, :integer
    field :tweet_ids, {:array, :string}

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :tweet_ids])
    |> validate_required([:user_id])
  end
end
