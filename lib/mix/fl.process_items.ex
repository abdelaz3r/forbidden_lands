defmodule Mix.Tasks.Fl.ProcessItems do
  @shortdoc "TODO"

  @moduledoc """
  TODO
  """

  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    {options, _, _} =
      OptionParser.parse(args,
        strict: [
          directory: :string,
          source_file: :string,
          prompt_file: :string,
          openai_api_key: :string,
          openai_org: :string,
          openai_timout: :integer,
          deepl_api_key: :string,
          source_lang: :string,
          target_lang: :string
        ]
      )

    required_options = [
      :directory,
      :source_file,
      :prompt_file,
      :openai_api_key,
      :openai_org,
      :deepl_api_key
    ]

    unless Enum.all?(required_options, fn option -> Keyword.has_key?(options, option) end) do
      Mix.shell().error("Missing options. Required options are #{inspect(required_options)}")
      exit(1)
    end

    # Default options
    directory = Keyword.fetch!(options, :directory)
    source_file = Keyword.fetch!(options, :source_file)
    prompt_file = Keyword.fetch!(options, :prompt_file)

    openai_api_key = Keyword.fetch!(options, :openai_api_key)
    openai_org = Keyword.fetch!(options, :openai_org)
    openai_timout = Keyword.get(options, :openai_timout, 60_000)

    deepl_api_key = Keyword.get(options, :deepl_api_key)
    source_lang = Keyword.get(options, :source_lang, "EN")
    target_lang = Keyword.get(options, :target_lang, "FR")

    # OpenAI config
    openai_config = %OpenAI.Config{
      api_key: openai_api_key,
      organization_key: openai_org,
      http_options: [recv_timeout: openai_timout]
    }

    {:ok, openai_prompt} = File.read(Path.join(directory, prompt_file))

    # DeepL config
    deepl_config = %{
      source_lang: source_lang,
      target_lang: target_lang,
      auth_key: deepl_api_key
    }

    # Read source file
    items =
      read_source!(Path.join(directory, source_file))
      |> Enum.take_random(10)

    Mix.shell().info("Process items:")
    Mix.shell().info("Source file: #{Path.join(directory, source_file)}")
    Mix.shell().info("Source items count: #{length(items)}")
    Mix.shell().info("")
    Mix.shell().info("Open AI config:")
    Mix.shell().info("Api key: #{openai_api_key}")
    Mix.shell().info("Organization key: #{openai_org}")
    Mix.shell().info("Timeout: #{openai_timout}ms")
    Mix.shell().info("Prompt file: #{Path.join(directory, prompt_file)}")
    Mix.shell().info("")
    Mix.shell().info("Translation config:")
    Mix.shell().info("Api key: #{deepl_api_key}")
    Mix.shell().info("Source langage: #{source_lang}")
    Mix.shell().info("Target langage: #{target_lang}")
    Mix.shell().info("")
    Mix.shell().info("Processing...")
    Mix.shell().info("It may take a while...")
    Mix.shell().info("")

    # Pipeline to process items
    results =
      items
      |> Enum.with_index(fn item, index ->
        {:ok, Map.put(item, "id", index)}
      end)
      |> Task.async_stream(
        fn item ->
          item
          |> normalize()
          |> atomize()
          |> summarize(openai_config, openai_prompt)
          |> split_description()
          |> translate(deepl_config)
        end,
        timeout: openai_timout,
        on_timeout: :kill_task,
        zip_input_on_exit: true
      )
      |> Enum.map(fn
        {:ok, item} -> item
        {:exit, {{:ok, item}, reason}} -> {:error, :pipeline, reason, item}
      end)

    success =
      Enum.filter(results, fn
        {:ok, _item} -> true
        _error -> false
      end)

    failure =
      Enum.filter(results, fn
        {:ok, _item} -> false
        _error -> true
      end)

    Mix.shell().info("Result:")
    Mix.shell().info("#{length(success)} items processed successfully")

    Enum.each(failure, fn {:error, type, _reason, item} ->
      Mix.shell().error("* Item #{item["id"]} failed during #{type}")
    end)

    Mix.shell().info("")

    # Write results
    success_json = Poison.encode!(success |> Enum.map(fn {:ok, item} -> item end), %{pretty: true})
    File.write!(Path.join(directory, "out-success.json"), success_json)
    failed_json = Poison.encode!(failure |> Enum.map(fn {:error, _, _, item} -> item end), %{pretty: true})
    File.write!(Path.join(directory, "out-failed.json"), failed_json)

    Mix.shell().info("Successfull results:")
    Mix.shell().info("Write:")
    Mix.shell().info("Save successfull items to #{Path.join(directory, "out-success.json")}")
    Mix.shell().info("Save failed items to #{Path.join(directory, "out-failed.json")}")
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

  defp normalize({:ok, item}) do
    keys = ["name"] ++ if(item["ingredient"], do: ["ingredient"], else: [])

    item =
      Enum.reduce(keys, item, fn key, acc ->
        Map.put(acc, key, Map.get(acc, key) |> String.downcase() |> String.capitalize())
      end)

    {:ok, item}
  end

  defp atomize({:ok, item}) do
    item =
      Enum.reduce(["type", "range", "duration"], item, fn key, acc ->
        Map.put(acc, key, Map.get(acc, key) |> String.downcase())
      end)

    {:ok,
     %{
       item
       | "type" => do_atomize(item["type"]),
         "range" => do_atomize(item["range"]),
         "duration" => do_atomize(item["duration"])
     }}
  end

  defp do_atomize("awareness"), do: :awareness
  defp do_atomize("blood magic"), do: :blood_magic
  defp do_atomize("death magic"), do: :death_magic
  defp do_atomize("general"), do: :general
  defp do_atomize("healing"), do: :healing
  defp do_atomize("shapeshifting"), do: :shapeshifting
  defp do_atomize("stone song"), do: :stone_song
  defp do_atomize("symbolism"), do: :symbolism

  defp do_atomize("arm’s length"), do: :arms_length
  defp do_atomize("distant"), do: :distant
  defp do_atomize("long"), do: :long
  defp do_atomize("near"), do: :near
  defp do_atomize("personal"), do: :personal
  defp do_atomize("short"), do: :short
  defp do_atomize("unlimited"), do: :unlimited

  defp do_atomize("immediate"), do: :immediate
  defp do_atomize("one round"), do: :round
  defp do_atomize("one round per power level"), do: :round_per_level
  defp do_atomize("one turn (15 minutes)"), do: :turn
  defp do_atomize("one turn per power level"), do: :turn_per_level
  defp do_atomize("quarter day"), do: :quarter
  defp do_atomize("quarter day per power level"), do: :quarter_per_level

  defp do_atomize("varies"), do: :varies
  defp do_atomize(_), do: :unknown

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

  defp translate({:ok, %{"ingredient" => ""} = item}, config) do
    texts = [item["name"], item["description"]["header"]] ++ item["description"]["summary"]

    case do_translate(texts, item, config) do
      {:ok, [n, h | s]} ->
        {:ok, %{item | "name" => n, "description" => %{"header" => h, "summary" => s}}}

      error ->
        error
    end
  end

  defp translate({:ok, item}, config) do
    texts = [item["name"], item["ingredient"], item["description"]["header"]] ++ item["description"]["summary"]

    case do_translate(texts, item, config) do
      {:ok, [n, i, h | s]} ->
        {:ok, %{item | "name" => n, "ingredient" => i, "description" => %{"header" => h, "summary" => s}}}

      error ->
        error
    end
  end

  defp translate(error, _config),
    do: error

  defp do_translate(texts, item, config) do
    request = %HTTPoison.Request{
      method: :post,
      url: "https://api-free.deepl.com/v2/translate",
      body:
        Poison.encode!(%{
          text: texts,
          source_lang: config.source_lang,
          target_lang: config.target_lang
        }),
      headers: [
        {"Authorization", "DeepL-Auth-Key #{config.auth_key}"},
        {"Content-Type", "application/json"},
        {"Accept", "application/json"}
      ]
    }

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.request(request),
         {:ok, response} <- Poison.decode(body),
         %{"translations" => translations} <- response do
      {:ok, Enum.map(translations, fn %{"text" => text} -> text end)}
    else
      {:error, reason} -> {:error, :translate, reason, item}
      reason -> {:error, :translate, reason, item}
    end
  end
end
