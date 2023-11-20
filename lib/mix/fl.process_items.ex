defmodule Mix.Tasks.Fl.ProcessItems do
  @shortdoc "TODO"

  @moduledoc """
  TODO
  """

  use Mix.Task

  # alias ForbiddenLands.Instances.Event
  # alias ForbiddenLands.Instances.Instances

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    {options, _, _} =
      OptionParser.parse(args,
        strict: [
          source: :string,
          apikey: :string,
          orgkey: :string
        ]
      )

    unless Keyword.has_key?(options, :source) do
      Mix.shell().error("A source file is required.")
      exit(1)
    end

    unless Keyword.has_key?(options, :apikey) do
      Mix.shell().error("An api key is required.")
      exit(1)
    end

    unless Keyword.has_key?(options, :orgkey) do
      Mix.shell().error("An organization key is required.")
      exit(1)
    end

    # Default options
    source = Keyword.fetch!(options, :source)
    api_key = Keyword.fetch!(options, :apikey)
    org_key = Keyword.fetch!(options, :orgkey)

    # OpenAI config
    openai_timout = 60_000

    openai_config = %OpenAI.Config{
      api_key: api_key,
      organization_key: org_key,
      http_options: [recv_timeout: openai_timout]
    }

    openai_prompt = "
      Extract the 2 to 5 key points of the following content.
      Output these key points as a markdown list.
      The first item in the list should be a very short summary of the content, explaining what it does. Treat it as a normal list item, do not prepend anything to it (espacially NOT `- Summary: `).
      All following items should be short sentences that describe the rules and the effects of the content. Keep each list element as short as possible, try to summarize the list item.
      Only output that list.
      Overall, be as concise as possible.
    "

    # Read source file
    items =
      read_source!(source)
      |> Enum.take_random(2)

    # ...
    Mix.shell().info("Process items:")
    Mix.shell().info("Source file: #{source}")
    Mix.shell().info("Source items count: #{length(items)}")
    Mix.shell().info("")
    Mix.shell().info("Open AI config:")
    Mix.shell().info("Api key: #{api_key}")
    Mix.shell().info("Organization key: #{org_key}")
    Mix.shell().info("Timeout: #{openai_timout}")
    Mix.shell().info("")
    Mix.shell().info("Processing:")

    # Pipeline to process items
    return =
      items
      |> Enum.with_index(fn item, index ->
        {:ok, Map.put(item, "id", index)}
      end)
      |> Task.async_stream(
        fn item ->
          item
          |> print_step("normalize")
          |> normalize()
          |> print_step("summarize")
          |> summarize(openai_config, openai_prompt)
          |> print_step("spliting description")
          |> split_description()
        end,
        timeout: openai_timout,
        on_timeout: :kill_task,
        zip_input_on_exit: true
      )
      |> Enum.map(fn
        {:ok, item} -> item
        {:exit, {{:ok, item}, reason}} -> {:error, :pipeline, reason, item}
      end)

    IO.inspect(return)
    IO.inspect(length(return))
  end

  defp read_source!(source) do
    with {:ok, body} <- File.read(source),
         {:ok, json} <- Poison.decode(body) do
      json
    else
      {:error, error} ->
        Mix.shell().error("Error:")
        Mix.shell().error(error)

      error ->
        Mix.shell().error("Error:")
        Mix.shell().error(error)
    end
  end

  defp print_step({:ok, item}, label) do
    Mix.shell().info("* #{String.capitalize(label)} [item #{item["id"]}]")
    {:ok, item}
  end

  defp print_step({:error, type, reason, item}, label) do
    Mix.shell().info("* Skip #{label} [item #{item["id"]}]")
    {:error, type, reason, item}
  end

  defp normalize({:ok, item}) do
    keys =
      ["name", "type", "range", "duration"] ++
        if(item["ingredient"], do: ["ingredient"], else: [])

    item =
      Enum.reduce(keys, item, fn key, acc ->
        Map.put(acc, key, Map.get(acc, key) |> String.downcase() |> String.capitalize())
      end)

    {:ok, item}
  end

  defp summarize({:ok, item}, config, prompt) do
    messages = [%{role: "system", content: prompt}, %{role: "user", content: item["description"]}]
    response = OpenAI.chat_completion([model: "gpt-3.5-turbo", messages: messages], config)

    case response do
      {:ok, %{choices: choices}} ->
        resp = List.first(choices)
        desc = resp["message"]["content"]

        {:ok, %{item | "description" => desc}}

      {:error, error} ->
        {:error, :summarizing, error, item}
    end
  end

  defp split_description({:ok, item}) do
    [header | summary] =
      item["description"]
      |> String.trim_leading("- ")
      |> String.split("\n- ")

    if length(summary) > 0 do
      {:ok, %{item | "description" => %{"header" => header, "summary" => summary}}}
    else
      {:error, :split_description, :cannot_split_description, item}
    end
  end

  defp split_description(error),
    do: error
end
