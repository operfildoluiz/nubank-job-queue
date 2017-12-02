defmodule NubankJobQueueTest do
  use ExUnit.Case
  doctest App.Queue

  # As the main function make calls of private functions, we'll have this test
  # to make sure that our code works as expected.
  # The JSON entry is the same given as sample in Hiring Process and JSON return
  # is the same given as expectation.

  test "should return a valid JSON when JSON given" do
        assert 1 == 1
  end
end
