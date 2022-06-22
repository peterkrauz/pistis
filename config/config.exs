import Config

config :pistis, machine: Example.KVStore
config :pistis, cluster_size: 5
config :pistis, cluster_boot_delay: 4000
config :pistis, known_hosts: [
  :pistis_node_1@localhost,
  :pistis_node_2@localhost,
  :pistis_node_3@localhost,
  :pistis_node_4@localhost,
  :pistis_node_5@localhost
]
