defmodule Pistis.Server do
  alias Pistis.Request
  alias Pistis.Cluster.Manager, as: ClusterManager

  def send_request(request_body) do
    case :ra.process_command(ClusterManager.leader_node(), %Request{body: request_body}) do
      {:ok, response, _} -> response
      error -> error
    end
  end
end
