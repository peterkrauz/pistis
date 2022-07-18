# Pistis

An Elixir library to reduce the boilerplate work one would have in order to implement a distributed cluster of strongly-consistent BEAM instances.

Pistis ensures deterministic commands through [`:ra`](https://github.com/rabbitmq/ra), an Erlang-based implementation of the [Raft](https://www.usenix.org/conference/atc14/technical-sessions/presentation/ongaro)consensus protocol.

## Installation

1. Add the `pistis` artifact to you project's dependencies

```elixir
def deps do
  [
    {:pistis, "~> 0.1.10"}
  ]
end
```

2. Define your state machine module on `config/config.exs`

```elixir
config :pistis, machine: YourApp.YourStateMachine
```

3. Add the library's entrypoint supervisor to your Elixir app's children

```elixir
defmodule YourApp.Application do
  # ...
  def start(_type, _args) do
    children = [Pistis.Core.Entrypoint]
    opts = [strategy: :one_for_one, name: YourApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

4. Profit

## Usage

The library demands two things from its user:

1. Make sure client commands are sent to Pistis' server

```elixir
defmodule YourApp.SomeModule do
  def your_fn_that_increments_state_by_2(_args) do
    Pistis.Server.send_request({:increment_by, 2})
  end

  def another_fn_but_a_shy_one(_args) do
    Pistis.Server.send_request(:increment)
  end
end
```

2. A concrete state-machine

```elixir
defmodule YourApp.StateMachine do
  @behaviour Pistis.Machine

  def initial_state, do: 0

  def process_command(%Pistis.Request{body: :increment}, current_state) do
    %Pistis.Response(response: :ok, state: current_state + 1)
  end

  def process_command(%Pistis.Request{body: {:increment_by, num}}, current_state) do
    %Pistis.Response(response: :ok, state: current_state + num)
  end
end
```

Pistis does not inspect your message's content. It simply wraps your state-machine implementation with a Raft-aware component that takes care of delivering the request and getting a response out of it.

All requests are wrapped inside the `Pistis.Request` struct. Responses should follow the same pattern by being wrapped in a `Pistis.Response` struct.

## Examples

Example state-machines can be found at `lib/example`
