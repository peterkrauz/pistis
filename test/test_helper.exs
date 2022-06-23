defmodule TestCluster do
  # def boot_test_nodes() do
  #   cluster_size = Application.get_env(:pistis, :cluster_size, 5)

  #   :net_kernel.start([:"primary@127.0.0.1"])

  #   :erl_boot_server.start([])
  #   to_charlist("127.0.0.1") |> allow_boot()

  #   :net_kernel.monitor_nodes(true)
  #   :os.cmd('epmd -daemon')

  #   Node.start(:master@localhost, :shortnames)
  #   Enum.each(1..cluster_size, fn index -> spawn_node("pistis_node_#{index}@127.0.0.1") end)
  #   {:ok, cluster_size}
  # end

  def spawn(nodes) do
    # Turn node into a distributed node with the given long name
    :net_kernel.start([:"primary@127.0.0.1"])

    # Allow spawned nodes to fetch all code from this node
    :erl_boot_server.start([])
    allow_boot to_charlist("127.0.0.1")

    # :net_kernel.monitor_nodes(true)
    # :os.cmd('epmd -daemon')

    nodes |> Enum.map(&Task.async(fn -> spawn_node(&1) end))
  end

  defp spawn_node(node_host) do
    {:ok, node} = :slave.start(to_charlist("127.0.0.1"), node_name(node_host), inet_loader_args())
    add_code_paths(node)
    transfer_configuration(node)
    ensure_applications_started(node)
    {:ok, node}
  end

  defp node_name(node_host) do
    node_host
    |> to_string
    |> String.split("@")
    |> Enum.at(0)
    |> String.to_atom
  end

  defp inet_loader_args do
    to_charlist("-loader inet -hosts 127.0.0.1 -setcookie #{:erlang.get_cookie()}")
  end

  defp rpc(node, module, function, args) do
    :rpc.block_call(node, module, function, args)
  end

  defp allow_boot(host) do
    {:ok, ipv4} = :inet.parse_ipv4_address(host)
    :erl_boot_server.add_slave(ipv4)
  end

  defp add_code_paths(node) do
    rpc(node, :code, :add_paths, [:code.get_path()])
  end

  defp transfer_configuration(node) do
    for {app_name, _, _} <- Application.loaded_applications() do
      for {key, val} <- Application.get_all_env(app_name) do
        rpc(node, Application, :put_env, [app_name, key, val])
      end
    end
  end

  defp ensure_applications_started(node) do
    rpc(node, Application, :ensure_all_started, [:mix])
    rpc(node, Mix, :env, [Mix.env()])
    for {app_name, _, _} <- Application.loaded_applications() do
      rpc(node, Application, :ensure_all_started, [app_name])
    end
  end
end

ExUnit.start()
