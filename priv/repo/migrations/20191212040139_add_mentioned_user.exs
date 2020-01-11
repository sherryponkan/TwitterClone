defmodule TwitterClone.Repo.Migrations.AddMentionedUser do
  use Ecto.Migration

  def change do
    create table(:mentioned_users) do
      add :user_id, :integer
      add :tweet_ids, {:array, :string}

      timestamps()
    end
  end
end
