import Config

config :pistis, machine: Example.KVStore
config :pistis, cluster_size: 15
config :pistis, cluster_boot_delay: 4000
config :pistis, native_cluster: true
