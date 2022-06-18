import Config

config :pistis, machine: Example.KVStore
config :pistis, cluster_size: 5
config :pistis, cluster_boot_delay: 3500
config :pistis, native_cluster: false
