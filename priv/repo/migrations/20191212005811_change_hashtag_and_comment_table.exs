defmodule TwitterClone.Repo.Migrations.ChangeHashtagAndCommentTable do
  use Ecto.Migration

  def change do
    alter table(:tweets) do
      remove :tag_id
    end

    alter table(:hashtags) do
      add :tweet_ids, {:array, :string}, default: []
    end
  end
end
