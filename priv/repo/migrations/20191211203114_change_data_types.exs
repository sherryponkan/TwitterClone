defmodule TwitterClone.Repo.Migrations.ChangeDataTypes do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :follower_ids
      remove :following_ids
      add :follower_ids, {:array, :string}, default: []
      add :followering_ids, {:array, :string}, default: []
    end
  end
end
