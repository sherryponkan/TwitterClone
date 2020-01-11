defmodule TwitterClone.Hashtag do
  use TwitterClone.Web, :model

  schema "hashtags" do
    field :tag, :string
    field :tweet_ids, {:array, :string}, default: []
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:tag, :tweet_ids])
    |> validate_required([:tag])
  end
end
