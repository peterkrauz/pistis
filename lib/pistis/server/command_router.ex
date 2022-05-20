defmodule Pistis.Server.CommandRouter do
  alias Pistis.Cluster.Manager

  def route_message(message) do
    case :ra.process_command(Manager.leader_node(), message) do
      {:ok, response, _} -> response
      error -> error
    end
  end

end
