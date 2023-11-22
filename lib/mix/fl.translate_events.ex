defmodule Mix.Tasks.Fl.TranslateEvents do
  @shortdoc "Translate events of an instance."

  @moduledoc """
  This task will translate events of an instance from a language to another.
  This is an experimental task, use it at your own risk.
  This task uses the DeepL API to translate events, you will need to have a
  DeepL account and an API key to use it.

  You can find infos about the DeepL API Free plan here:
  https://www.deepl.com/pro#developer

  Available options are:
  * `--instance`: the instance id to translate (required)
  * `--auth-key`: the DeepL API authentication key (required)
  * `--offset`: the offset of the first event to translate (default: 0)
  * `--limit`: the maximum number of events to translate (default: 1000)
  * `--source`: the source language (default: FR)
  * `--target`: the target language (default: EN-GB)

  The list of supported languages can be found here:
  https://www.deepl.com/docs-api/translate-text/translate-text

  Usage example:
  ``` sh
  mix fl.translate_events \
    --instance 3 \
    --auth-key "my-api-key" \
    --limit 30 \
    --offset 5 \
    --source "EN" \
    --target "FR"
  ```
  """

  use Mix.Task

  alias ForbiddenLands.Instances.Event
  alias ForbiddenLands.Instances.Instances

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    {options, _, _} =
      OptionParser.parse(args,
        strict: [
          instance: :integer,
          auth_key: :string,
          offset: :integer,
          limit: :integer,
          source: :string,
          target: :string
        ]
      )

    unless Keyword.has_key?(options, :instance) do
      Mix.shell().error("An instance id is required.")
      exit(1)
    end

    unless Keyword.has_key?(options, :auth_key) do
      Mix.shell().error("A Deepl API authentication key is required.")
      exit(1)
    end

    # Default options
    instance_id = Keyword.fetch!(options, :instance)
    auth_key = Keyword.fetch!(options, :auth_key)
    offset = Keyword.get(options, :offset, 0)
    limit = Keyword.get(options, :limit, 1000)
    source_lang = Keyword.get(options, :source, "FR")
    target_lang = Keyword.get(options, :target, "EN-GB")

    options = [source_lang: source_lang, target_lang: target_lang, auth_key: auth_key]

    Mix.shell().info("Translate events of instance ##{instance_id}:")
    Mix.shell().info("Source lang: '#{source_lang}'")
    Mix.shell().info("Target lang: '#{target_lang}'")
    Mix.shell().info("This task will translate at most #{limit} events from offset #{offset}")
    Mix.shell().info("")

    # Start http poison is case it's not started yet
    HTTPoison.start()

    translated_events_count =
      instance_id
      |> Instances.list_events(types: Event.types(), offset: offset, limit: limit)
      |> Enum.map(fn event -> translate_event(event, options) end)
      |> Enum.filter(fn status -> status == :translated end)
      |> Enum.count()

    Mix.shell().info("")
    Mix.shell().info("#{translated_events_count} events translated.")
  end

  defp translate_event(%{title: title, description: description} = event, options) do
    texts =
      if description,
        do: [title, description],
        else: [title]

    case do_request(texts, options) do
      {:ok, content} ->
        params =
          case content do
            [title, description] -> %{"title" => title, "description" => description}
            [title] -> %{"title" => title}
          end

        event
        |> Event.create_from_export(params)
        |> Map.put(:action, :update)
        |> Instances.update_event()

        Mix.shell().info("* Event ##{event.id} translated")
        :translated

      {:error, error} ->
        Mix.shell().error("Error on http request (the event will not be updated):")
        Mix.shell().error(inspect(error, pretty: true))
        :not_translated
    end
  end

  defp do_request(texts, options) do
    source_lang = Keyword.fetch!(options, :source_lang)
    target_lang = Keyword.fetch!(options, :target_lang)
    auth_key = Keyword.fetch!(options, :auth_key)

    request = %HTTPoison.Request{
      method: :post,
      url: "https://api-free.deepl.com/v2/translate",
      body:
        Poison.encode!(%{
          text: texts,
          source_lang: source_lang,
          target_lang: target_lang,
          preserve_formatting: true
        }),
      headers: [
        {"Authorization", "DeepL-Auth-Key #{auth_key}"},
        {"Content-Type", "application/json"},
        {"Accept", "application/json"}
      ]
    }

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.request(request),
         {:ok, response} <- Poison.decode(body),
         %{"translations" => translatations} <- response do
      texts = Enum.map(translatations, fn %{"text" => text} -> text end)
      {:ok, texts}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end
end
