defmodule Pistis.Cluster.Loader do
  use GenServer

  @me __MODULE__
  @delay 2500

  def start_link(args \\ []), do: GenServer.start_link(@me, args, name: @me)

  def init(state) do
    self_send(:load_cluster)
    {:ok, state}
  end

  def handle_info(:load_cluster, state) do
    Pistis.Cluster.Manager.start_cluster()
    self_send(:stop)
    {:noreply, state}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  defp self_send(msg) do
    :timer.sleep(@delay)
    send(self(), msg)
  end
end
