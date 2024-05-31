defmodule BlockingBufferTest do
  use ExUnit.Case
  doctest BlockingBuffer

  test "greets the world" do
    assert BlockingBuffer.hello() == :world
  end
end
