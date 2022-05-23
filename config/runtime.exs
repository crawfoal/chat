 import Config

 config :plug,
   port: System.get_env("PORT", "4001") |> String.to_integer(),
   run: System.get_env("RUN_PLUG") === "true"
