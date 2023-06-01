defprotocol ForbiddenLands.Export do
  @moduledoc """
  TODO
  """

  @spec export(struct()) :: String.t()
  def export(data)
end

defimpl ForbiddenLands.Export, for: Any do
  defmacro __deriving__(module, _struct, options) do
    quote do
      defimpl ForbiddenLands.Export, for: unquote(module) do
        alias ForbiddenLands.Export

        def export(data) do
          [fields: fields] = unquote(options)

          data
          |> Map.from_struct()
          |> Enum.filter(fn {key, value} -> key in fields end)
          |> Enum.map(fn {key, value} ->
            value =
              cond do
                is_struct(value) ->
                  Export.export(value)

                is_list(value) ->
                  value
                  |> Enum.map(fn item -> Export.export(item) end)
                  |> Enum.reverse()

                true ->
                  value
              end

            {key, value}
          end)
          |> Enum.into(%{})
        end
      end
    end
  end

  @spec export(struct()) :: String.t()
  def export(_data) do
    "not implemented"
  end
end
