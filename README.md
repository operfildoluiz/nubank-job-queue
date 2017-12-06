[![20132106327144.jpg](https://s8.postimg.org/of5yopnt1/20132106327144.jpg)](https://postimg.org/image/npn6ccn9d/)

# The context

Since Nubank is a large company, it's very important to assure quality and efficiency in Customer Experience. As customers make questions through social media and service channels, a job queue service sounds good to improve speed and agility in the process of answering everyone.

# The proposal

Given a JSON string via stdin, the algorithm must be able to assign jobs to agents, ensuring that it follows some rules:

 - First in, first out: The first job entered in the system should be assigned first, unless it has an urgent flag.
 - A job cannot be assigned to more than one agent.
 - An agent has two skillsets, so he can't get a job whose type is not among those skillsets.
 - An agent only receives a job whose type is contained among his secondary skillset if no job from his primary skillset is available.

# Considerations

Although the solution seems pretty simple, there are many relevant business rules that might be considered.

First of all: this is a real problem (already solved at Nubank), and a very important one. That's why it was necessary to focus in error prevention and feedback.

It was interesting to use a more verbose language. Elixir sounds good for this purpose.

The code was developed following the Elixir community style guide, available at [this repository](https://github.com/lexmag/elixir-style-guide)

# The main solution

The algorithm follows this logical course:

 1. Given the JSON, use [Poison](https://github.com/devinus/poison) to decode it.
 2. `convert_json_to_map` function transforms the JSON in a useful list, performing input validations and reordering the job queue by their urgency.
 3. Having a reliable maplist, `assign_jobs_to_agents` function verifies, for every job_request, which job is more adequated for which agent. Also, there is a validator to make sure that the agent assigned really exists. If a job is found, the function returns a fresh maplist, dequeueing the job.
 4. When all the job requests are assigned, `prepare_encoding` will convert the result in a JSON file.

[![nubank.png](https://s8.postimg.org/dbqxwzhnp/nubank.png)](https://postimg.org/image/s7ph4kt29/)

# Development considerations

During the development period, some situations had to be resolved:

- Some fields must be required! There is no way to assign a job to an agent if the type has not been informed, for example.
- Types matter. It is extremely important to ensure that the primary_skillset field is a list, not a string, for example.

To deal with situations like this, it seemed interesting to work with custom Validators. Therefore, the algorithm makes use of three modules that check types and relevant fields.

To ensure the quality of information processing, I developed a script in Lumen that generated a few hundred records to be tested in the homologation environment.

# Running

Before running the algorithm, the dependencies must be installed. Considering Elixir is already installed in the environment, open the project in Terminal and type

    mix deps.get

Then, run it

    iex -S mix

Wait for iex starting process, then type:

    App.Queue.main

You can pass a JSON as a string (surrounded by single apostrophe). Otherwise, You'll be prompted to enter the JSON. Just copy and paste and press Enter. Please, make sure to enter a minified JSON.
