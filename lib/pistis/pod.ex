defmodule Pistis.Pod do
  alias Pistis.Pod.Raft

  def start(), do: :ra.start()

  def boot_raft(pod_address) do
    :rpc.call(pod_address, Pistis.Pod, :start, [])
    Raft.to_server_id(pod_address)
  end
end
