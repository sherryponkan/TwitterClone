defmodule TwitterClone.Repo.Migrations.AddHashtags do
  use Ecto.Migration

  def change do
    create table(:hashtags) do
      add :tag, :string
    end

    alter table(:tweets) do
      add :tag_id, references(:hashtags)
    end
  end
end
