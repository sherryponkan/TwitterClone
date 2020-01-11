use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :twitterClone, TwitterClone.Endpoint,
  secret_key_base: "ILJ3eJf+w831eQ1Zaz0tNXZ9SiMIQBTrz+vUz2BnIgXh4AeB1h0hgma3uL1625mI"

# Configure your database
config :twitterClone, TwitterClone.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "twitterclone_prod",
  pool_size: 20
