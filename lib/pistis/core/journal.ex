defmodule Pistis.Core.Journal do

  @spec __using__(any) :: {:__block__, [], [{:def, [...], [...]} | {:import, [...], [...]}, ...]}

  defmacro __using__(_) do
    quote do
      import IO.ANSI

      def scribe(msg) do
        node_name = "[#{cyan()}#{Node.self}#{reset()}]"
        module_name = " ~> #{yellow()}#{Kernel.inspect self()}#{reset()}"
        pids = "#{bright()}#{magenta()}#{pretty_name()}#{reset()}"
        IO.puts("#{node_name} #{pids}: #{msg}")
      end

      def pretty_name(), do: pretty_name(__MODULE__)

      def pretty_name(module) do
        {_, module_parts} = String.split(Atom.to_string(module), ".") |> List.pop_at(0)
        Enum.join(module_parts, ".")
      end
    end
  end
end
