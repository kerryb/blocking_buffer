defmodule BlockingBuffer.Buffer do
  @moduledoc false
  use Task

  #
  # Client
  #

  def start_link(size), do: Task.start_link(__MODULE__, :run, [size])

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

  def state(buffer) do
    send(buffer, {:get_state, self()})

    receive do
      {:reply, state} -> {:ok, state}
    end
  end

  #
  # Server
  #

  def run(size), do: wait(%{state: :empty, queue: :queue.new(), size: size})

  defp wait(%{state: :empty} = state) do
    receive do
      {:push, item, from} -> handle_push(state, item, from)
      {:get_state, from} -> handle_get_state(state, from)
    end
  end

  defp wait(%{state: :normal} = state) do
    receive do
      {:push, item, from} -> handle_push(state, item, from)
      {:pop, from} -> handle_pop(state, from)
      {:get_state, from} -> handle_get_state(state, from)
    end
  end

  defp wait(%{state: :full} = state) do
    receive do
      {:pop, from} -> handle_pop(state, from)
      {:get_state, from} -> handle_get_state(state, from)
    end
  end

  defp handle_push(state, item, from) do
    queue = :queue.in(item, state.queue)
    send(from, :noreply)

    if :queue.len(queue) == state.size do
      wait(%{state | state: :full, queue: queue})
    else
      wait(%{state | state: :normal, queue: queue})
    end
  end

  defp handle_pop(state, from) do
    {{:value, item}, queue} = :queue.out(state.queue)
    send(from, {:reply, item})

    if :queue.is_empty(queue) do
      wait(%{state | state: :empty, queue: queue})
    else
      wait(%{state | state: :normal, queue: queue})
    end
  end

  defp handle_get_state(state, from) do
    send(from, {:reply, state})
    wait(state)
  end
end
