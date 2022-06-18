defmodule Pistis.Application do
  @moduledoc false
  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  @native_cluster Application.get_env(:pistis, :native_cluster, false)

  @impl Application
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Pistis.Supervisor]
    Supervisor.start_link(get_app_children(), opts)
  end

  def get_app_children() do
    case @native_cluster do
      true -> [Pistis.DynamicSupervisor]
      false -> [Pistis.DynamicSupervisor, Pistis.Cluster.Observer, {Cluster.Supervisor, [topologies(), [name: Pistis.ClusterSupervisor]]}]
    end
  end

  defp topologies() do
    [
      pistis: [strategy: Cluster.Strategy.Gossip]
    ]
  end
end
