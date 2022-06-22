defmodule Pistis.Application do
  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  @known_hosts Application.get_env(:pistis, :known_hosts, [])

  @impl Application
  def start(_type, _args) do
    children = app_children(known_hosts: @known_hosts)
    opts = [strategy: :one_for_one, name: Pistis.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp app_children(known_hosts: []), do: base_children()

  defp app_children(known_hosts: _) do
    # When connecting to running BEAM nodes, use libcluster's supervisor.
    libcluster_supervisor = {Cluster.Supervisor, [topologies(), [name: Pistis.ClusterSupervisor]]}
    [libcluster_supervisor | base_children()]
  end

  defp base_children(), do: [Pistis.Core.Supervisor, Pistis.Cluster.Observer]

  def topologies() do
    [
      pistis: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: @known_hosts]
      ]
    ]
  end
end
