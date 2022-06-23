defmodule Pistis.Cluster.StateRefresher do
  use GenServer
  use Pistis.Core.Journal

  @me __MODULE__
  @heartbeat 2000

  def boot(), do: Pistis.Core.Supervisor.supervise(@me)

  def start_link(_args \\ []), do: GenServer.start_link(@me, %{}, name: @me)

  def init(state) do
    schedule_work(@heartbeat * 5)
    {:ok, state}
  end

  def handle_info(:work, state) do
    scribe("Refreshing cluster state...")
    Pistis.Cluster.Manager.refresh_cluster_state()
    schedule_work(@heartbeat)
    {:noreply, state}
  end

  defp schedule_work(delay) do
    Process.send_after(self(), :work, delay)
  end
end
