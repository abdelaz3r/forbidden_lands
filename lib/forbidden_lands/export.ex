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
        def export(data) do
          [fields: fields] = unquote(options)

          data
          |> Map.from_struct()
          |> Enum.filter(fn {key, value} -> key in fields end)
          |> Enum.map(fn {key, value} ->
            value =
              cond do
                is_struct(value) ->
                  ForbiddenLands.Export.export(value)

                is_list(value) ->
                  Enum.map(value, fn item -> ForbiddenLands.Export.export(item) end)

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
