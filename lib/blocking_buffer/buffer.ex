defmodule BlockingBuffer.Buffer do
  @moduledoc false
  use Task

  #
  # Client
  #

  def start_link(arg), do: Task.start_link(__MODULE__, :run, [arg])

  def push(buffer, item) do
    send(buffer, {:push, item, self()})

    receive do
      :noreply -> :ok
    end
  end

  def pop(buffer) do
    send(buffer, {:pop, self()})

    receive do
      {:reply, item} -> item
    end
  end

  #
  # Server
  #

  def run(_arg), do: wait(:empty, :queue.new())

  defp wait(:empty, queue) do
    receive do
      {:push, item, from} -> handle_push(queue, item, from)
    end
  end

  defp wait(:normal, queue) do
    receive do
      {:push, item, from} -> handle_push(queue, item, from)
      {:pop, from} -> handle_pop(queue, from)
    end
  end

  defp handle_push(queue, item, from) do
    send(from, :noreply)
    wait(:normal, :queue.in(item, queue))
  end

  defp handle_pop(queue, from) do
    {{:value, item}, queue} = :queue.out(queue)
    send(from, {:reply, item})
    wait(:normal, queue)
  end
end
