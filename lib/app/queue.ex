defmodule App.Queue do
    @moduledoc """
    Queue is the main module of the application.
    """


    @doc """
    Start the application.

    Returns a JSON.

    """
    def main() do

        IO.gets("Please, insert minified json: \n") |> String.replace("\n", "")
        |> Poison.decode!
        |> convert_json_to_map()
        |> assign_jobs_to_agents()

    end

    @doc """
    Create a list to be assigned, ordering jobs by urgent.

    Returns a keyword maplist.

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
   Set a new maplist with reordered job list.

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


   @doc """
   Create a new maplist with :assignment list and dequeue job list

   Return a new maplist
   """
   # Make sure this function receives proper arguments
   defp assign_jobs_to_agents(map), do: assign_jobs_to_agents(map, map[:requests])
   defp assign_jobs_to_agents(map, requests) do
        if (length(requests) == 0) do
            map
        else
            request = hd(requests)
            agent = map[:agents][String.to_atom(request["agent_id"])]

            if (agent == nil) do
                raise ArgumentError, "agent_id does not match with any agent"
            end

            primary_search = find_elegible_job(map[:jobs], agent["primary_skillset"])
            selected_job =
            if(primary_search != nil) do
                primary_search
            else
                find_elegible_job(map[:jobs], agent["secondary_skillset"])
            end

            new_map =
            if (selected_job != nil) do
                set_assignment(selected_job, agent["id"], map)
            else
                map
            end

            assign_jobs_to_agents(new_map, tl(requests))
        end
   end

   @doc """
   Find a elegible ob based in agent skillsets

   Return a job id
   """
   defp find_elegible_job(jobs, skillset) do
        if (length(jobs) == 0) do
            nil
        else
            job = elem(hd(jobs), 1)
            if(Enum.member?(skillset, job["type"])) do
                job["id"]
            else
                find_elegible_job(tl(jobs), skillset)
            end
        end
   end

   @doc """
   Set a new assignment with agent_id and job_id given

   Return a maplist
   """
   defp set_assignment(job_id, agent_id, map) do
        if (map[:assignments] == nil) do
            set_assignment(job_id, agent_id, Keyword.put(map, :assignments, []))
        else
            assignment = [job_assigned: %{agent_id: agent_id, job_id: job_id}]
            jobs = Keyword.drop(map[:jobs], [String.to_atom(job_id)]);

            [agents: map[:agents], jobs: jobs, requests: map[:requests], assignments: map[:assignments] ++ assignment]
        end
   end
end
