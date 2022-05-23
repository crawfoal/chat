defmodule Chat do
  @moduledoc """
  Documentation for `Chat`.
  """

  def receive_message(message, from) do
    IO.puts(message)
    if Regex.match?(~r/moebi@/, Atom.to_string(Node.self())) do
      send_message(from, "chicken?")
    end
  end

  def send_message(recipient, message) do
    spawn_task(__MODULE__, :receive_message, recipient, [message, Node.self()])
  end

  def spawn_task(module, fun, recipient, args) do
    recipient
    |> remote_supervisor()
    |> Task.Supervisor.async(module, fun, args)
    |> Task.await()
  end

  defp remote_supervisor(recipient) do
    {Chat.TaskSupervisor, recipient}
  end
end
