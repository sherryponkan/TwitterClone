defmodule TwitterClone.Repo.Migrations.ChangeUserColName do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :followering_ids
      add :following_ids, {:array, :string}, default: []
    end
  end
end
