defmodule TwitterClone.User do
  use TwitterClone.Web, :model

  schema "users" do
    field :user_name, :string
    field :password, :string
    field :follower_ids, {:array, :string}, default: []
    field :following_ids, {:array, :string}, default: []
    has_many :tweets, TwitterClone.Tweet
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_name, :password, :follower_ids, :following_ids])
    |> validate_required([:user_name, :password])
  end
end
