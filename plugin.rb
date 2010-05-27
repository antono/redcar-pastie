Plugin.define do
  name    "pastie"
  version "0.1"
  file    "lib", "pastie"
  object  "Redcar::Pastie"
  dependencies "redcar", ">0"
end