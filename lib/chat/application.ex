defmodule Chat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Chat.TaskSupervisor},
    ]

    if Application.get_env(:plug, :run) do
      IO.puts("Plug on... will listen on port #{Application.get_env(:plug, :port)}")
      children = children ++ {
        Plug.Cowboy, scheme: :http, plug: Chat.Router, options: [
          port: Application.get_env(:plug, :port)
        ]
      }
    end

    IO.puts("Node name: #{Node.self()}")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
