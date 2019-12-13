bench_func = fn (n) -> Primex.under(n) |> Enum.to_list() end

Benchee.run(
  %{
    :primes_under_1_000 => fn -> bench_func.(1_000) end,
    :primes_under_10_000 => fn -> bench_func.(10_000) end,
    :primes_under_100_000 => fn -> bench_func.(100_000) end,
    :primes_under_1_000_000 => fn -> bench_func.(1_000_000) end,
    # :primes_under_10_000_000 => fn -> bench_func.(10_000_000) end
  },
  formatters: [
    Benchee.Formatters.HTML,
    Benchee.Formatters.Console
  ]
)
