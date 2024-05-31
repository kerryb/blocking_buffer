defmodule BlockingBuffer.Buffer do
  use Task

  def start_link(arg), do: Task.start_link(__MODULE__, :run, [arg])

  def run(_arg), do: wait(:queue.new())

  defp wait(queue) do
    receive do
      {:push, item, from} ->
        send(from, :noreply)
        wait(:queue.in(item, queue))

      {:pop, from} ->
        {{:value, item}, queue} = :queue.out(queue)
        send(from, {:reply, item})
        wait(queue)
    end
  end

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
end
