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

  @spec smlt(integer, integer) :: cis
  defp smlt(c, inc) do
    {c, fn -> smlt(c + inc, inc) end}
  end

  @spec smult(integer) :: cis
  defp smult(p) do
    smlt(p * p, p + p)
  end

  P
  @spec allmults(cis) :: ciss
  defp allmults({p, restps}) do
    {smult(p), fn -> allmults(restps.()) end}
  end

  @spec pairs(ciss) :: ciss
  defp pairs({cs0, restcss0}) do
    {cs1, restcss1} = restcss0.()
    {merge(cs0, cs1), fn -> pairs(restcss1.()) end}
  end

  @spec cmpsts(ciss) :: cis
  defp cmpsts({cs, restcss}) do
    {c, restcs} = cs
    {c, fn -> merge(restcs.(), cmpsts(pairs(restcss.()))) end}
  end

  @spec minusat(integer, cis) :: cis
  defp minusat(n, cmps) do
    {c, restcs} = cmps

    if n < c do
      {n, fn -> minusat(n + 2, cmps) end}
    else
      minusat(n + 2, restcs.())
    end
  end

  @spec oddprms() :: cis
  defp oddprms() do
    {3,
     fn ->
       {5, fn -> minusat(7, cmpsts(allmults(oddprms()))) end}
     end}
  end

  @doc """
  Primes sieve

  ## Examples

      iex> Primex.primes() |> Stream.take(25) |> Enum.to_list()
      [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

  """
  @spec primes() :: Enumerable.t()
  def primes do
    [2]
    |> Stream.concat(
      Stream.iterate(oddprms(), fn {_, restps} -> restps.() end)
      |> Stream.map(fn {p, _} -> p end)
    )
  end

  @doc """
  Primes under limit

  ## Examples

    iex> Primex.under(100) |> Enum.to_list()
    [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

  """
  @spec under(integer()) :: Enumerable.t()
  def under(n) when is_integer(n) do
    primes()
    |> Stream.take_while(&(&1 < n))
  end
end

# range = 1000000
# IO.write "The first 25 primes are:\n( "
# PrimesSoETreeFolding.primes() |> Stream.take(25) |> Enum.each(&(IO.write "#{&1} "))
# IO.puts ")"
# testfunc =
#   fn () ->
#     ans =
#       PrimesSoETreeFolding.primes() |> Stream.take_while(&(&1 <= range)) |> Enum.count()
#     ans end
# :timer.tc(testfunc)
#   |> (fn {t,ans} ->
#     IO.puts "There are #{ans} primes up to #{range}."
#     IO.puts "This test bench took #{t} microseconds." end).()
