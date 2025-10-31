%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
        excluded: []
      },
      plugins: [],
      requires: [],
      strict: true,
      parse_timeout: 5000,
      color: true,
      checks: [
        {Credo.Check.Design.AliasUsage, [if_nested_deeper_than: 2]},
        {Credo.Check.Readability.MaxLineLength, [max_length: 120]},
        {Credo.Check.Readability.AliasAs, false},
        {Credo.Check.Readability.OnePipePerLine, false}
      ]
    }
  ]
}
