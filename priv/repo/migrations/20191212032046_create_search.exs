defmodule TwitterClone.Repo.Migrations.CreateSearch do
  use Ecto.Migration

  def change do
    create table(:searchs) do
      add :content, :string

      timestamps()
    end

  end
end
