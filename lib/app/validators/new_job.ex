defmodule App.Validators.NewJob do
    @moduledoc """
    Validate required fields and do type-checking of a new_job item
    """

    def validate(item) do

        cond do
          (item["id"] == nil) ->
            raise ArgumentError, "new_job should have an id"
          (item["type"] == nil) ->
            raise ArgumentError, "new_job should have a type"
          (item["urgent"] == nil) ->
            raise ArgumentError, "new_job should have a urgent flag"
          true ->
            if(correct_types?(item)) do
                item
            else
                nil
            end
        end
    end

    defp correct_types?(item) do
        cond do
           (!is_boolean(item["urgent"])) ->
                raise ArgumentError, "urgent should be boolean"
           true ->
                true
        end
    end
end
