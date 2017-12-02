defmodule App.Queue do
    @moduledoc """
    Queue is the main module of the application.
    """


    @doc """
    Start the application.

    Returns a JSON.

    ## Example

        iex> App.Queue.main()
        [{\"job_assigned\": {\"job_id\": \"c0033410-981c-428a-954a-35dec05ef1d2\",\"agent_id\": \"8ab86c18-3fae-4804-bfd9-c3d6e8f66260\"}},{\"job_assigned\": {\"job_id\": \"f26e890b-df8e-422e-a39c-7762aa0bac36\",\"agent_id\": \"ed0e23ef-6c2b-430c-9b90-cd4f1ff74c88\"}}]

    """
    def main() do

        IO.gets("Please, insert minified json: \n") |> String.replace("\n", "")
        |> Poison.decode!
        |> convert_json_to_map()

    end

    @doc """
    Create a list to be assigned, ordering jobs by urgent.

    Returns a keyword maplist.

    ## Example

        iex> App.Queue.convert_json_to_map(input, maplist)
        [agents: ["ed0e23ef-6c2b-430c-9b90-cd4f1ff74c88": %{"id" => "ed0e23ef-6c2b-430c-9b90-cd4f1ff74c88", "name" => "Mr. Peanut Butter", "primary_skillset" => ["rewards-question"], "secondary_skillset" => ["bills-questions"]}, "8ab86c18-3fae-4804-bfd9-c3d6e8f66260": %{"id" => "8ab86c18-3fae-4804-bfd9-c3d6e8f66260", "name" => "BoJack Horseman", "primary_skillset" => ["bills-questions"], "secondary_skillset" => []}], jobs: ["c0033410-981c-428a-954a-35dec05ef1d2": %{"id" => "c0033410-981c-428a-954a-35dec05ef1d2", "type" => "bills-questions", "urgent" => true}, "f26e890b-df8e-422e-a39c-7762aa0bac36": %{"id" => "f26e890b-df8e-422e-a39c-7762aa0bac36", "type" => "rewards-question", "urgent" => false}, "690de6bc-163c-4345-bf6f-25dd0c58e864": %{"id" => "690de6bc-163c-4345-bf6f-25dd0c58e864", "type" => "bills-questions", "urgent" => false}], requests: [%{"agent_id" => "8ab86c18-3fae-4804-bfd9-c3d6e8f66260"}, %{"agent_id" => "ed0e23ef-6c2b-430c-9b90-cd4f1ff74c88"}]]

    """
    # Make sure maplist have proper structure
    defp convert_json_to_map(input), do: convert_json_to_map(input, [agents: [], jobs: [], requests: []])
    defp convert_json_to_map(input, maplist) do
        if (length(input) == 0) do
            # Returns a reverse maplist because jobs that arrived first should be assigned first
            [agents: maplist[:agents], jobs: Enum.reverse(maplist[:jobs]), requests: maplist[:requests]] |> sort_jobs_by_urgency()
        else
            item = hd(input)

            new_maplist =
            cond do
                (item["new_agent"] != nil) ->
                        agent = App.Validators.NewAgent.validate(item["new_agent"])
                        new = Keyword.put(maplist[:agents], String.to_atom(item["new_agent"]["id"]), agent)
                        [agents: new, jobs: maplist[:jobs], requests: maplist[:requests]]
                (item["new_job"] != nil) ->
                        job = App.Validators.NewJob.validate(item["new_job"])
                        new = Keyword.put(maplist[:jobs], String.to_atom(item["new_job"]["id"]), job)
                        [agents: maplist[:agents], jobs: new, requests: maplist[:requests]]
                (item["job_request"] != nil) ->
                        job_request = App.Validators.JobRequest.validate(item["job_request"])
                        [agents: maplist[:agents], jobs: maplist[:jobs], requests: maplist[:requests] ++ [job_request]]
                true ->
                        maplist
           end

           convert_json_to_map(tl(input), new_maplist)
       end
   end

   @doc """
   Returns a reorder maplist.
   """
   defp sort_jobs_by_urgency(maplist) do
        if(maplist[:jobs] == nil) do
            raise ArgumentError, "maplist should have jobs keyword"
        else
            [agents: maplist[:agents], jobs: reorder_job_list(maplist[:jobs], []), requests: maplist[:requests]]
        end

   end

   @doc """
   Reorder jobs keyword list based in its urgent flag

   Return a list of jobs
   """
   defp reorder_job_list(jobs, list) do
        if ((length(jobs) == 0)) do
            list
        else
            job = elem(hd(jobs), 1)
            if (job["urgent"] == true) do
                reorder_job_list(tl(jobs), [hd(jobs) | list])
            else
                reorder_job_list(tl(jobs), list ++ [hd(jobs)])
            end
        end
   end

end
