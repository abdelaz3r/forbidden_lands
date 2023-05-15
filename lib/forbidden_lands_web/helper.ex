defmodule ForbiddenLandsWeb.Live.Helper do
  @moduledoc false

  alias Phoenix.HTML

  @spec text_to_raw_html(String.t(), String.t()) :: {:safe, String.t()}
  def text_to_raw_html(content, class \\ "") do
    content
    |> HTML.Format.text_to_html(attributes: [class: class])
    |> HTML.safe_to_string()
    |> String.replace("&lt;%", "<strong class=\"font-bold text-white\">")
    |> String.replace("%&gt;", "</strong>")
    |> HTML.raw()
  end
end
