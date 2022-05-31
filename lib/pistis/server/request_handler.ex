defmodule Pistis.Server.RequestHandler do
  def process(message), do: route_message(message)

  defp route_message(message) do
    case :ra.process_command(Pistis.Cluster.Manager.leader_node(), message) do
      {:ok, response, _} -> response
      error -> error
    end
  end
end
