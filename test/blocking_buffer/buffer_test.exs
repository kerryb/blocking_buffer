defmodule BlockingBuffer.BufferTest do
  use ExUnit.Case, async: true

  alias BlockingBuffer.Buffer

  describe "BlockingBuffer.Buffer" do
    setup do
      %{buffer: start_supervised!(Buffer)}
    end

    test "acts as a first in, first out buffer", %{buffer: buffer} do
      Buffer.push(buffer, :foo)
      Buffer.push(buffer, :bar)
      assert Buffer.pop(buffer) == :foo
      assert Buffer.pop(buffer) == :bar
    end

    test "blocks reads when empty", %{buffer: buffer} do
      pid = self()

      Task.async(fn ->
        item = Buffer.pop(buffer)
        send(pid, {:popped, item})
      end)

      refute_receive {:popped, _}
      Buffer.push(buffer, :foo)
      assert_receive {:popped, :foo}
    end
  end
end
