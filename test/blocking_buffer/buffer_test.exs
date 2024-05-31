defmodule BlockingBuffer.BufferTest do
  alias BlockingBuffer.Buffer
  use ExUnit.Case, async: true

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
  end
end