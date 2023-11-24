defmodule Mix.Tasks.Fl.ProcessSpells do
  @shortdoc "[EXPERIMENTAL] Process and translate spells."

  @moduledoc """
  This is an experimental task, use it at your own risk!

  This task will try to take a list of structured extracted spells and process them to:
  - normalize the data
  - transform some fields to atoms
  - summarize and split the description using OpenAI API
  - translate the data using DeepL API
  - write the results to a given directory

  Here is the shape of input item:
  ``` json
  {
    "type" => "type",
    "name" => "NAME",
    "rank" => 1,
    "range" => "Range",
    "duration" => "Duration ",
    "ingredient" => "Ingredient",
    "is_ritual" => false,
    "is_power_word" => false,
    "description" => "Description"
  }
  ```

  Here is the shape of output item:
  ``` json
  {
    "type": :atom, # Atomized type
    "name": String.t(), # Capitalized name
    "rank": :integer, # [1, 2, 3]
    "range": :atom, # Atomized range
    "ingredient": String.t(), # Capitalized ingredient
    "duration": :atom, # Atomized duration
    "is_official": true, # Always true
    "is_ritual": true|false,
    "is_power_word": true|false,
    "do_consume_ingredient": true, # Always true (you need to set it yourselfs)
    "description": {
      "header": String.t(), # Key point extracted using OpenAI
      "summary": [String.t()], # Rest of points extracted using OpenAI
    },
    "full_description": String.t() # Unchanged description
  },
  ```

  You can find infos about the OpenAI API plan here:
  https://platform.openai.com/docs/overview

  You can find infos about the DeepL API Free plan here:
  https://www.deepl.com/pro#developer

  Available options are:
  * `--directory`: the working directory where the files are located (required)
  * `--source-file`: the source file name (required)
  * `--prompt-file`: the prompt file name (required)
  * `--openai-api-key`: the OpenAI API key (required)
  * `--openai-org`: the OpenAI organization key (required)
  * `--openai-timout`: the OpenAI API timeout in milliseconds (default: 60000ms)
  * `--translate`: translate the content into the target langage (default: false)
  * `--deepl-api-key`: the DeepL API authentication key (required if translate is true)
  * `--source-lang`: the source language (default: EN)
  * `--target-lang`: the target language (default: FR)

  The list of supported languages can be found here:
  https://www.deepl.com/docs-api/translate-text/translate-text

  Usage example:
  ``` sh
  mix fl.process_spells \
    --directory /some/path/to/the/working/directory \
    --source-file structured-input.json \
    --prompt-file openai-prompt.txt \
    --openai-api-key "mykey" \
    --openai-org "myorg" \
    --translate \
    --deepl-api-key "mykey"
  ```
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
          translate: :boolean,
          deepl_api_key: :string,
          source_lang: :string,
          target_lang: :string
        ]
      )

    # Parse options
    translate? = Keyword.get(options, :translate, false)
    required_options = [:directory, :source_file, :prompt_file, :openai_api_key, :openai_org]
    required_options = if translate?, do: required_options ++ [:deepl_api_key], else: required_options

    unless Enum.all?(required_options, fn option -> Keyword.has_key?(options, option) end) do
      error("Missing options. Required options are #{inspect(required_options)}")
      exit(1)
    end

    # Default options
    directory = Keyword.fetch!(options, :directory)
    source_file = Keyword.fetch!(options, :source_file)
    prompt_file = Keyword.fetch!(options, :prompt_file)

    openai_api_key = Keyword.fetch!(options, :openai_api_key)
    openai_org = Keyword.fetch!(options, :openai_org)
    openai_timout = Keyword.get(options, :openai_timout, 60_000)

    deepl_api_key = Keyword.get(options, :deepl_api_key, nil)
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
    deepl_config =
      if translate?,
        do: %{source_lang: source_lang, target_lang: target_lang, auth_key: deepl_api_key},
        else: nil

    # Read source file
    items =
      Path.join(directory, source_file)
      |> read_source!()
      |> Enum.with_index(fn item, index -> {:ok, Map.put(item, "id", index)} end)

    # Print task infos
    print("Process items:")
    print("Source file: #{Path.join(directory, source_file)}")
    print("Source items count: #{length(items)}")
    print("")
    print("Open AI config:")
    print("Api key: #{openai_api_key}")
    print("Organization key: #{openai_org}")
    print("Timeout: #{openai_timout}ms")
    print("Prompt file: #{Path.join(directory, prompt_file)}")
    print("")
    print("Translation config:")
    print("Api key: #{deepl_api_key}")
    print("Source langage: #{source_lang}")
    print("Target langage: #{target_lang}")
    print("")
    print("Processing...")
    print("This may take a while...")
    print("")

    # Pipeline to process items
    {success, failure} = process(items, {openai_config, openai_prompt, translate?, deepl_config, openai_timout})

    # Postprocess results
    success =
      success
      |> List.flatten()
      |> Enum.map(fn {:ok, item} -> item end)
      |> Enum.sort(fn %{"id" => id1}, %{"id" => id2} -> id1 < id2 end)

    failure = Enum.map(failure, fn {:ok, item} -> item end)

    print("Successfull results:")
    print("Write:")
    print("Save successfull items to #{Path.join(directory, "out-success.json")}")
    print("Save failed items to #{Path.join(directory, "out-failed.json")}")

    # Write results
    File.write!(Path.join(directory, "out-success.json"), Poison.encode!(success, %{pretty: true}))
    File.write!(Path.join(directory, "out-failed.json"), Poison.encode!(failure, %{pretty: true}))
  end

  # Pipeline

  defp process(items, configs), do: process(items, [], 1, configs)
  defp process([], processed, _iteration, _config), do: {processed, []}
  defp process(to_process, processed, iteration, _config) when iteration > 5, do: {processed, to_process}

  defp process(to_process, processed, iteration, configs) do
    print("Iteration #{iteration}")
    print("#{length(to_process)} items to process.")
    print("")

    {openai_config, openai_prompt, translate?, deepl_config, openai_timout} = configs

    {success, failed} =
      to_process
      |> Task.async_stream(
        fn item ->
          item
          |> prepare()
          |> normalize()
          |> atomize()
          |> summarize(openai_config, openai_prompt)
          |> split_description()
          |> translate(translate?, deepl_config)
        end,
        timeout: openai_timout,
        on_timeout: :kill_task,
        zip_input_on_exit: true
      )
      |> Enum.map(fn
        {:ok, item} -> item
        {:exit, {{:ok, item}, reason}} -> {:error, :pipeline, reason, item}
      end)
      |> Enum.reduce({[], []}, fn
        {:ok, item}, {success, failure} -> {[{:ok, item} | success], failure}
        {:error, type, reason, item}, {success, failure} -> {success, [{:error, type, reason, item} | failure]}
      end)

    print("Result:")
    print("#{length(success)}/#{length(to_process)} successfully processed items.")
    print("#{length(failed)}/#{length(to_process)} unsuccessfully processed items.")

    Enum.each(failed, fn {:error, type, _r, item} ->
      error("* Item #{item["id"]} failed during #{type}")
    end)

    print("")

    next_ids_to_process = Enum.map(failed, fn {:error, _t, _r, %{"id" => id}} -> id end)
    next_to_process = Enum.filter(to_process, fn {:ok, %{"id" => id}} -> id in next_ids_to_process end)

    process(next_to_process, [success | processed], iteration + 1, configs)
  end

  # Pipeline functions

  defp prepare({:ok, item}) do
    item =
      item
      |> Map.put("is_official", true)
      |> Map.put("do_consume_ingredient", true)
      |> Map.put("full_description", item["description"])

    {:ok, item}
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
    splitted =
      item["description"]
      |> String.trim_leading("- ")
      |> String.split("\n- ")

    if length(splitted) >= 2 do
      [header | summary] = splitted
      {:ok, %{item | "description" => %{"header" => header, "summary" => summary}}}
    else
      {:error, :split_description, :cannot_split_description, item}
    end
  end

  defp split_description(error),
    do: error

  defp translate(item, false, _config),
    do: item

  defp translate({:ok, %{"ingredient" => nil} = item}, _translate?, config) do
    texts = [item["name"], item["description"]["header"]] ++ item["description"]["summary"]

    case do_translate(texts, item, config) do
      {:ok, [n, h | s]} ->
        {:ok, %{item | "name" => n, "description" => %{"header" => h, "summary" => s}}}

      error ->
        error
    end
  end

  defp translate({:ok, item}, _translate?, config) do
    texts = [item["name"], item["ingredient"], item["description"]["header"]] ++ item["description"]["summary"]

    case do_translate(texts, item, config) do
      {:ok, [n, i, h | s]} ->
        {:ok, %{item | "name" => n, "ingredient" => i, "description" => %{"header" => h, "summary" => s}}}

      error ->
        error
    end
  end

  defp translate(error, _translate?, _config),
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

  # Helpers functions

  defp read_source!(source) do
    with {:ok, body} <- File.read(source),
         {:ok, json} <- Poison.decode(body) do
      json
    else
      {:error, error} ->
        error("Error:")
        error(error)

      error ->
        error("Error:")
        error(error)
    end
  end

  defp print(message), do: Mix.shell().info(message)
  defp error(message), do: Mix.shell().error(message)
end
