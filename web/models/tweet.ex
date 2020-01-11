defmodule TwitterClone.Tweet do
  use TwitterClone.Web, :model
  @derive {Poison.Encoder, only: [:content]}
  schema "tweets" do
    field :content, :string
    belongs_to :user, TwitterClone.User
    
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content])
    |> validate_required([:content])
  end
end
