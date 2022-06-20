defmodule Pistis.Server do
  alias Pistis.Cluster.Manager
  alias Pistis.Machine.Request
  alias Pistis.Machine.Response

  @spec send_request(any) :: Response | tuple()

  def send_request(request_body) do
    case :ra.process_command(Manager.any_node(), %Request{body: request_body}) do
      {:ok, response, _} -> response
      error -> error
    end
  end
end
