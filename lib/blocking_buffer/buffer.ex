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
      {:push, item, from} ->
        send(from, :noreply)
        wait(:normal, :queue.in(item, queue))
    end
  end

  defp wait(:normal, queue) do
    receive do
      {:push, item, from} ->
        send(from, :noreply)
        wait(:normal, :queue.in(item, queue))

      {:pop, from} ->
        {{:value, item}, queue} = :queue.out(queue)
        send(from, {:reply, item})
        wait(:normal, queue)
    end
  end
end
