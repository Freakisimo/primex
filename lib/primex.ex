defmodule Primex do
  @moduledoc """
  This is an educational exercise in refactoring someone else's
  code. The original source comes from
  http://rosettacode.org/wiki/Sieve_of_Eratosthenes#Elixir
  """

  @typedoc """
  `t:cis` is a user-defined type, which is a tuple of
  an integer and a function that resolves to another `t:cis`
  """
  @type cis :: {integer, (() -> cis)}

  @typedoc """
  `t:ciss` is a user-defined type, which is a tuple of
  a `t:cis` (above) and a function that resolves to another `t:ciss`
  """
  @type ciss :: {cis, (() -> ciss)}

  @spec merge(cis, cis) :: cis
  defp merge(xs, ys) do
    {x, restxs} = xs
    {y, restys} = ys

    cond do
      x < y -> {x, fn -> merge(restxs.(), ys) end}
      y < x -> {y, fn -> merge(xs, restys.()) end}
      true -> {x, fn -> merge(restxs.(), restys.()) end}
    end
  end

  @spec stream_multiples_internal(integer, integer) :: cis
  defp stream_multiples_internal(c, inc) do
    {c, fn -> stream_multiples_internal(c + inc, inc) end}
  end

  @spec stream_multiples(integer) :: cis
  defp stream_multiples(p) do
    stream_multiples_internal(p * p, p + p)
  end

  @spec all_multiples(cis) :: ciss
  defp all_multiples({p, restps}) do
    {stream_multiples(p), fn -> all_multiples(restps.()) end}
  end

  @spec pairs(ciss) :: ciss
  defp pairs({cs0, restcss0}) do
    {cs1, restcss1} = restcss0.()
    {merge(cs0, cs1), fn -> pairs(restcss1.()) end}
  end

  @spec composites(ciss) :: cis
  defp composites({cs, restcss}) do
    {c, restcs} = cs
    {c, fn -> merge(restcs.(), composites(pairs(restcss.()))) end}
  end

  @spec remove_multiples(integer, cis) :: cis
  defp remove_multiples(n, cmps) do
    # n is a potential prime number
    {c, restcs} = cmps

    if n < c do
      {n, fn -> remove_multiples(n + 2, cmps) end}
    else
      remove_multiples(n + 2, restcs.())
    end
  end

  @spec odd_primes() :: cis
  defp odd_primes() do
    {3,
     fn ->
       {5,
        fn ->
          comp =
            odd_primes()
            |> all_multiples()
            |> composites()

          remove_multiples(7, comp)
        end}
     end}
  end

  @doc """
  Get a Primes sieve stream

  ## Examples

      iex> Primex.stream() |> Stream.take(25) |> Enum.to_list()
      [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

      iex> Primex.stream() |> Stream.take_while(&(&1 < 100)) |> Enum.to_list()
      [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

  """
  @spec stream() :: Enumerable.t()
  def stream do
    [2]
    |> Stream.concat(
      Stream.iterate(odd_primes(), fn {_, restps} -> restps.() end)
      |> Stream.map(fn {p, _} -> p end)
    )
  end

  @doc """
  Get a stream of Primes under the given limit

  ## Examples

    iex> Primex.under(100) |> Enum.to_list()
    [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

  """
  @spec under(integer()) :: Enumerable.t()
  def under(n) when is_integer(n) do
    stream()
    |> Stream.take_while(&(&1 < n))
  end
end
