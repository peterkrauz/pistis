defmodule Pistis.Cluster.ConnectionRetry do
  use GenServer
  alias Pistis.Cluster.State, as: ClusterState

  @me __MODULE__
  @heartbeat 2000

  def start_link(), do: GenServer.start_link(@me, %{})

  def init(state) do
    schedule_work(@heartbeat * 4)
    {:ok, state}
  end

  def handle_info(:work, state) do
    Pistis.Cluster.StateStorage.read() |> attempt_reconnection()
    schedule_work(@heartbeat)
    {:noreply, state}
  end

  defp attempt_reconnection(%ClusterState{leader: _, failures: failures, members: _}) do
    failures
  end

  defp schedule_work(delay), do: Process.send_after(self(), :work, delay)
end
