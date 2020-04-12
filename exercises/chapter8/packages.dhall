let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.6-20200404/packages.dhall sha256:f239f2e215d0cbd5c203307701748581938f74c4c78f4aeffa32c11c131ef7b6

let overrides =
      { form-urlencoded = upstream.form-urlencoded // { version = "v4.0.0" } }

let additions =
      { affjax =
          { dependencies =
            [ "arraybuffer-types"
            , "media-types"
            , "form-urlencoded"
            , "argonaut-core"
            , "aff"
            , "web-xhr"
            , "unsafe-coerce"
            , "refs"
            , "integers"
            , "math"
            , "foreign"
            , "http-methods"
            , "nullable"
            ]
          , repo = "https://github.com/slamdata/purescript-affjax.git"
          , version = "v9.0.1"
          }
      }

in  upstream // overrides // additions
