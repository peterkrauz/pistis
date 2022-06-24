defmodule Pistis.Server.RequestHandler do
  use GenServer, restart: :temporary
  alias Pistis.Cluster.Manager
  alias Pistis.Machine.Request

  @me __MODULE__
  @timeout :timer.minutes(1)

  def start_link(server_name) do
    GenServer.start_link(@me, server_name, name: server_name)
  end

  def init(state), do: {:ok, state, @timeout}

  def send_request(pid, request_body) do
    GenServer.call(pid, {:send_request, request_body})
  end

  # See which if handle_cast yields faster throughput
  def handle_call({:send_request, request_body}, _from, state) do
    response = :ra.process_command(Manager.any_node(), %Request{body: request_body})
    {:reply, parse_raft_response(response), state}
  end

  defp parse_raft_response({:ok, response, _}), do: response
  defp parse_raft_response(anything_else), do: {:error, anything_else}
end
