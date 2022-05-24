web: RUN_PLUG=true elixir --name "web@$HEROKU_PRIVATE_IP" --cookie "$ERLANG_COOKIE" -S mix run --no-halt
kate: elixir --name "kate@$HEROKU_PRIVATE_IP" --cookie "$ERLANG_COOKIE" -S mix run --no-halt
moebi: elixir --sname "moebi@$HEROKU_PRIVATE_IP" --cookie "$ERLANG_COOKIE" -S mix run --no-halt
alex: elixir --sname "alex@$HEROKU_PRIVATE_IP" --cookie "$ERLANG_COOKIE" -S mix run --no-halt
