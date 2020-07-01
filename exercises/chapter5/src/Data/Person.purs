module Data.Person where
  
type Address = { street :: String, city :: String }

type Person = { name :: String, address :: Address }
