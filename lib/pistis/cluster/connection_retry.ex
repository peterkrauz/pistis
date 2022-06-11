defmodule Pistis.Cluster.ConnectionRetry do
  use GenServer
  use Pistis.EnhancedLogger
  alias Pistis.Cluster.State, as: ClusterState

  @me __MODULE__
  @heartbeat 1500

  def boot(), do: Pistis.DynamicSupervisor.supervise(@me)

  def start_link(_args \\ []), do: GenServer.start_link(@me, %{}, name: @me)

  def init(state) do
    schedule_work(@heartbeat * 2)
    {:ok, state}
  end

  def handle_info(:work, state) do
    Pistis.Cluster.StateStorage.read() |> attempt_reconnection()
    {:noreply, state}
  end

  defp attempt_reconnection(%ClusterState{leader: _, failures: [], members: _}) do
    # log("attempt_reconnection/1 <> no failures")
    schedule_work(@heartbeat * 5)
  end

  defp attempt_reconnection(%ClusterState{leader: _, failures: failures, members: _}) do
    # log("attempt_reconnection/1 <> #{length(failures)} failures")
    Enum.each(failures, fn failed_node -> Pistis.Pod.RaftServer.dynamic_add(failed_node) end)
    schedule_work(@heartbeat)
  end

  defp schedule_work(delay), do: Process.send_after(self(), :work, delay)
end
