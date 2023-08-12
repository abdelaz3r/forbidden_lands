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
  * `--offset`: the offset of the first event to translate (default: 0)
  * `--limit`: the maximum number of events to translate (default: 1000)
  * `--source`: the source language (default: FR)
  * `--target`: the target language (default: EN-GB)
  """

  use Mix.Task

  require Logger

  alias ForbiddenLands.Instances.Event
  alias ForbiddenLands.Instances.Instances

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    {options, _, _} =
      OptionParser.parse(args,
        strict: [instance: :integer, offset: :integer, limit: :integer, source: :string, target: :string]
      )

    unless Keyword.has_key?(options, :instance) do
      Mix.shell().error("An instance id is required.")
      exit(1)
    end

    # Default options
    instance_id = Keyword.fetch!(options, :instance)
    offset = Keyword.get(options, :offset, 0)
    limit = Keyword.get(options, :limit, 1000)
    source_lang = Keyword.get(options, :source, "FR")
    target_lang = Keyword.get(options, :target, "EN-GB")

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
      |> Enum.map(fn event ->
        {event, params} = translate_event(event, source_lang, target_lang)

        event
        |> Event.create_from_export(params)
        |> Map.put(:action, :update)
        |> Instances.update_event()

        Mix.shell().info("* Event ##{event.id} translated")
      end)
      |> Enum.count()

    Mix.shell().info("")
    Mix.shell().info("#{translated_events_count} events translated.")
  end

  defp translate_event(%{title: title, description: nil} = event, source_lang, target_lang) do
    [title] = do_request([title], source_lang, target_lang)
    {event, %{"title" => title}}
  end

  defp translate_event(%{title: title, description: description} = event, source_lang, target_lang) do
    [title, description] = do_request([title, description], source_lang, target_lang)
    {event, %{"title" => title, "description" => description}}
  end

  defp do_request(texts, source_lang, target_lang) do
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
        {"Authorization", "DeepL-Auth-Key my-api-key"},
        {"Content-Type", "application/json"},
        {"Accept", "application/json"}
      ]
    }

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.request(request),
         {:ok, response} <- Poison.decode(body),
         %{"translations" => translatations} <- response do
      Enum.map(translatations, fn %{"text" => text} -> text end)
    else
      {:error, error} ->
        Logger.error("Error on http request:")
        IO.inspect(error)

      error ->
        Logger.error("Error:")
        IO.inspect(error)
    end
  end
end
