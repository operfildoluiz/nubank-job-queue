defmodule App.Validators.NewAgent do
    @moduledoc """
    Validate required fields and do type-checking of a new_agent item
    """

    def validate(item) do

        cond do
          (item["id"] == nil) ->
            raise ArgumentError, "new_agent should have an id"
          (item["primary_skillset"] == nil) ->
            raise ArgumentError, "new_agent should have a primary_skillset"
          (item["secondary_skillset"] == nil) ->
            raise ArgumentError, "new_agent should have a secondary_skillset"
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
           (!is_list(item["primary_skillset"])) ->
                raise ArgumentError, "primary_skillset should be a list"
           (!is_list(item["secondary_skillset"])) ->
                raise ArgumentError, "secondary_skillset should be a list"
           true ->
                true
        end
    end
end
