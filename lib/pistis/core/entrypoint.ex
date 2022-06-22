defmodule Pistis.Core.Entrypoint do
  use GenServer

  @me __MODULE__
  @delay 2500

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  @spec init(any) :: {:ok, any}

  def start_link(args \\ []), do: GenServer.start_link(@me, args, name: @me)

  def init(state) do
    self_send(:load_cluster)
    {:ok, state}
  end

  def handle_info(:load_cluster, state) do
    Pistis.Cluster.Manager.boot()
    Pistis.Cluster.ConnectionRetry.boot()
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
