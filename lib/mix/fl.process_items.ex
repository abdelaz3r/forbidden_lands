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
      |> Enum.take_random(2)

    # ...
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
          |> print_step("translate")
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
