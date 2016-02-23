defmodule ElixirGitlab.Util.Into do

  @doc """
  Given a result from Gitlab that may be either a single JSON
  object or an array of them, covert it into either a single struct
  or a list of structs of the passed-in type.
  """

  def into({ :ok, collection}, struct_name) when is_list(collection) do
    collection
    |> Enum.map(&into({:ok, &1}, struct_name))
  end

  def into({:ok, item}, struct_name) when is_map(item) do
    struct!(struct_name, item)
  end

  def into(error, _struct) do
    error
  end

end


