defmodule Pistis.Pod do
  alias Pistis.Pod.Raft
  alias Pistis.Cluster.Manager
  use Pistis.Core.Journal

  def start(), do: :ra.start()

  def create_pod(pod_index) do
    Task.async(fn -> boot_pod(pod_index) end)
  end

  defp boot_pod(pod_index) do
    pod_address = Manager.create_node(pod_index)
    Manager.wait()

    pod_address
    |> Manager.erlang_connect()
    |> boot_raft()
  end

  def boot_raft(pod_address) do
    :rpc.call(pod_address, Pistis.Pod, :start, [])
    Raft.to_server_id(pod_address)
  end
end
