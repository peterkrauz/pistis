defmodule Pistis.Application do
  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  @native_cluster Application.get_env(:pistis, :native_cluster, false)

  @impl Application
  def start(_type, _args) do
    children = app_children(native_cluster: @native_cluster)
    opts = [strategy: :one_for_one, name: Pistis.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp app_children(native_cluster: false) do
    libcluster_supervisor = {Cluster.Supervisor, [topologies(), [name: Pistis.ClusterSupervisor]]}
    [libcluster_supervisor | base_children()]
  end

  defp app_children(native_cluster: true), do: base_children()

  defp base_children(), do: [Pistis.Core.Supervisor, Pistis.Cluster.Observer]

  # defp topologies() do
  #   [
  #     pistis: [
  #       strategy: Cluster.Strategy.Gossip
  #     ]
  #   ]
  # end

  def topologies() do
    [
      pistis: [
        strategy: Cluster.Strategy.Epmd,
        config: [
          hosts: [
            :"pistis_node_1@localhost",
            :"pistis_node_2@localhost",
            :"pistis_node_3@localhost",
          ]
        ]
      ]
    ]
  end
end
