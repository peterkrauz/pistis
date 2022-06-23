import Config

config :pistis, machine: Example.KVStore
config :pistis, cluster_size: 5
config :pistis, cluster_boot_delay: 4000
config :pistis, known_hosts: [
  :"pistis_node_1@127.0.0.1",
  :"pistis_node_2@127.0.0.1",
  :"pistis_node_3@127.0.0.1",
  :"pistis_node_4@127.0.0.1",
  :"pistis_node_5@127.0.0.1"
]

import_config "#{Mix.env()}.exs"
