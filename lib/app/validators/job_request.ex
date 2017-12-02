defmodule App.Validators.JobRequest do
    @moduledoc """
    Validate required fields and do type-checking of a job_request item
    """

    def validate(item) do

        cond do
          (item["agent_id"] == nil) ->
            raise ArgumentError, "job_request should have an agent_id"
          true ->
            if(correct_types?(item)) do
                item
            else
                nil
            end
        end
    end

    defp correct_types?(item) do
        true
    end
end
