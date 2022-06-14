defmodule Pistis.Pod do
  alias Pistis.Pod.Raft
  alias Pistis.Cluster.Manager

  @cluster_boot_delay max(Application.get_env(:pistis, :cluster_boot_delay, 3500), 3500)

  def start() do
    :ra.start()
    # Also start some sort of health checker to
    # supervise this Node's Pistis.Pod.Machine
  end

  def boot_delay(), do: @cluster_boot_delay

  def create_pod(pod_index) do
    Task.async(fn -> pod_index|> Manager.create_node() |> erlang_connect() end)
  end

  def connect_to_pod(pod_index) do
    node_address = String.to_atom("pistis_node_#{pod_index}")
    erlang_connect(node_address)
  end

  defp erlang_connect(pod_address) do
    :timer.sleep(boot_delay())
    Node.connect(pod_address)
    :rpc.call(pod_address, Pistis.Pod, :start, [])
    Raft.to_server_id(pod_address)
  end
end
