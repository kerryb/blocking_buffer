defmodule BlockingBuffer.BufferTest do
  use ExUnit.Case, async: true

  alias BlockingBuffer.Buffer

  describe "BlockingBuffer.Buffer" do
    setup do
      %{buffer: start_supervised!({Buffer, 3})}
    end

    test "acts as a first in, first out buffer", %{buffer: buffer} do
      Buffer.push(buffer, :foo)
      Buffer.push(buffer, :bar)
      assert Buffer.pop(buffer) == :foo
      assert Buffer.pop(buffer) == :bar
    end

    test "blocks reads until the first item is pushed", %{buffer: buffer} do
      pid = self()

      task =
        Task.async(fn ->
          item = Buffer.pop(buffer)
          send(pid, {:popped, item})
        end)

      refute_receive {:popped, _}
      Buffer.push(buffer, :foo)
      assert_receive {:popped, :foo}
      Task.await(task)
    end

    test "blocks reads after the last item is popped, until another is pushed", %{buffer: buffer} do
      Buffer.push(buffer, :foo)
      Buffer.pop(buffer)

      pid = self()

      task =
        Task.async(fn ->
          item = Buffer.pop(buffer)
          send(pid, {:popped, item})
        end)

      refute_receive {:popped, _}
      Buffer.push(buffer, :bar)
      assert_receive {:popped, :bar}
      Task.await(task)
    end

    test "blocks writes when full", %{buffer: buffer} do
      Buffer.push(buffer, :foo)
      Buffer.push(buffer, :bar)
      Buffer.push(buffer, :baz)

      pid = self()

      task =
        Task.async(fn ->
          Buffer.push(buffer, :qux)
          send(pid, :pushed)
        end)

      refute_receive :pushed
      Buffer.pop(buffer)
      assert_receive :pushed
      Task.await(task)
    end

    test "allows its state to be queried for debugging", %{buffer: buffer} do
      Buffer.push(buffer, :foo)
      Buffer.push(buffer, :bar)
      assert Buffer.state(buffer) == %{size: 3, state: :normal, queue: :queue.from_list([:foo, :bar])}
    end
  end
end
