module = "luamml"

tdsroot      = "lualatex"
installfiles = { "luamml-*.lua", "*.sty" }
sourcefiles  = { "luamml-*.lua", "*.sty", "*.dtx" }
typesetsuppfiles = { "*.tex" }
typesetsourcefiles = { "*.tex" }
stdengine    = "luatex"
unpackfiles  = { "*.dtx" }
typesetexe   = "lualatex"
excludefiles = { "build.lua", "config-*.lua", "*-demo.sty"}

checkconfigs = {
  'config-lua',
  'config-pdf',
}
