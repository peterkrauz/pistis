import Config

config :pistis, machine: Example.KVStore
config :pistis, cluster_size: 5
config :pistis, raft_boot_delay: 3500
