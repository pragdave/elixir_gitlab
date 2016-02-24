defmodule ElixirGitlab.Util.Options do

  alias ElixirGitlab.API

  @doc """
  Make sure a given set of options has all the required keys,
  and that any remaining keys are listed in the set of
  optional entries. Return `{:ok, given}` on success, and
  `{:error, reason}` otherwise.

  Examples
  ========

        iex> import ElixirGitlab.Util.Options
        nil
        iex> spec = %{ required: MapSet.new([:name, :email]), optional: MapSet.new([:age, :height]) }
        iex> opts([name: "dave", email: "dave@", height: "yes"], spec)
        { :ok, [name: "dave", email: "dave@", height: "yes"]}
        iex> opts([name: "dave", height: "yes"], spec)
        { :error, "Required: [:email, :name] but given [:height, :name]" }
        iex> opts([name: "dave", email: "dave@", likes: "elixir"], spec)
        { :error, "Unknown option(s): [:likes]" }
  """
  def opts(given, spec) when is_list(given) do
    with keys = given |> Dict.keys |> MapSet.new,
         :ok <- opts_required(keys, spec),
         :ok <- opts_optional(keys, spec),
    do: { :ok, given }
  end

  def call_with_options(method, path, options, option_spec) do
    with { :ok, full_options } <- opts(options, option_spec),
    do:  apply(API, method, [path, full_options])
  end
  
  defp opts_required(given, %{ required: required }) do
    if MapSet.subset?(required, given) do
      :ok
    else
      { :error, "Required: #{members(required)} but given #{members(given)}" }
    end
  end

  defp opts_required(_given, _) do
    :ok
  end

  defp opts_optional(given, spec) do
    with remaining = given
                     |> MapSet.difference(maybe_missing(spec, :required))
                     |> MapSet.difference(maybe_missing(spec, :optional)) do
      if Set.size(remaining) == 0 do
        :ok
      else
        { :error, "Unknown option(s): #{members(remaining)}" }
      end
    end
  end

  defp members(set) do
    set
    |> Set.to_list
    |> inspect
  end

  defp maybe_missing(map, key) do
    Map.get(map, key, MapSet.new())
  end

end
