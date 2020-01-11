defmodule TwitterClone.Repo.Migrations.AddFollowingAndFollowers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :follower_ids, {:array, :integer}
      add :following_ids, {:array, :integer}
    end
  end
end
