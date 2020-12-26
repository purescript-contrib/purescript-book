let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.8-20201223/packages.dhall sha256:a1a8b096175f841c4fef64c9b605fb0d691229241fd2233f6cf46e213de8a185

let overrides =
      { test-unit =
        { dependencies =
          [ "aff"
          , "either"
          , "prelude"
          , "effect"
          , "quickcheck"
          , "free"
          , "strings"
          , "lists"
          , "js-timers"
          , "avar"
          ]
        , repo = "https://github.com/milesfrain/purescript-test-unit.git"
        , version = "stackless-default"
        }
      }

let additions = {=}

in  upstream // overrides // additions
