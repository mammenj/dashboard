# Dashboard

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

Here is config.exs

```

# General application configuration
import Config

config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :dashboard, Monitor.MyMailer,
  adapter: Swoosh.Adapters.Sendinblue,
  api_key: "your key"

config :kafka_ex,
  brokers: [{"localhost", 9092}],
  consumer_group: "ideapad",
  client_id: "idea-client",
  disable_default_worker: true,
  sync_timeout: 30000,
  max_restarts: 100,
  max_seconds: 30,
  commit_interval: 5_000,
  commit_threshold: 100,
  sleep_for_reconnect: 400,
  use_ssl: false,
  ssl_options: [],
  kafka_version: "kayrock"
  
import_config "#{config_env()}.exs"
```
