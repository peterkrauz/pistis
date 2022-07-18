defmodule Pistis.Cluster.Observer do
  use GenServer
  use Pistis.Core.Journal

  @me __MODULE__

  def start_link(_args), do: GenServer.start_link(@me, nil, name: @me)

  @impl GenServer
  def init(state) do
    :net_kernel.monitor_nodes(true)
    {:ok, state}
  end

  @impl GenServer
  def handle_info({:nodedown, node}, state) do
    scribe("--- Node down: #{node}")
    {:noreply, state}
  end

  def handle_info({:nodeup, node}, state) do
    scribe("--- Node up: #{node}")
    {:noreply, state}
  end
end
