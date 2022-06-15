let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.2-20220613/packages.dhall
        sha256:99f976d547980055179de2245e428f00212e36acd55d74144eab8ad8bf8570d8

let additions =
      { react-basic-hooks =
        { dependencies =
          [ "prelude"
          , "aff-promise"
          , "aff"
          , "console"
          , "datetime"
          , "effect"
          , "either"
          , "indexed-monad"
          , "maybe"
          , "newtype"
          , "numbers"
          , "react-basic"
          , "type-equality"
          , "unsafe-coerce"
          , "unsafe-reference"
          , "web-html"
          ]
        , repo =
            "https://github.com/megamaddu/purescript-react-basic-hooks.git"
        , version = "v8.0.0"
        }
      }

in  upstream // additions
