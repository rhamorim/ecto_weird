defmodule EctoWeird.Repo do
  use Ecto.Repo,
    otp_app: :ecto_weird,
    adapter: Ecto.Adapters.Postgres
end
