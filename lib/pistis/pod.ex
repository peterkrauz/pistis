defmodule Pistis.Pod do
  alias Pistis.Pod.Raft

  @node_suffix for _ <- 1..10, into: "", do: <<Enum.random('abc123')>>
  @cluster_boot_delay max(Application.get_env(:pistis, :cluster_boot_delay, 3500), 3500)

  def start() do
    :ra.start()
    # Also start some sort of health checker to
    # supervise this Node's Pistis.Pod.Machine
  end

  def boot_delay(), do: @cluster_boot_delay

  def boot_pod(pod_index) do
    Task.async(fn ->
      start_pod(pod_index)
      |> connect_to_pod()
      |> Raft.to_server_id()
    end)
  end

  defp start_pod(pod_index) do
    pod_address = "#{Raft.cluster_name()}_node_#{@node_suffix}_#{pod_index}@localhost"
    Task.async(fn -> System.shell("iex --sname #{pod_address} -S mix") end) # TODO: This line needs to change
    String.to_atom(pod_address)
  end

  defp connect_to_pod(pod_address) do
    :timer.sleep(boot_delay())
    Node.connect(pod_address)
    :rpc.call(pod_address, Pistis.Pod, :start, [])
    pod_address
  end
end
