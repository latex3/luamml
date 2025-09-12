--[[
   This file defines and returns the main function
   * write_elem(element,stash)
   which adds structure elements/tagging commands to the mathml

   The function has two arguments: tree (xml-tree), stash (boolean).
   The function is loaded by luamml-tex as `write_struct` and used there in
   save_result as `write_struct(mlist_result)` (so with stash=false/nil)
   and as `write_struct(xml, true)` in the callback.
--]]

-- Create tokens from the main tagpdf commands.
local struct_begin = token.create'tag_struct_begin:n'
local struct_use = token.create'tag_struct_use:n'
local struct_use_num = token.create'tag_struct_use_num:n'
local struct_end = token.create'tag_struct_end:'

local mc_begin = token.create'tag_mc_begin:n'
local mc_end = token.create'tag_mc_end:'

local tagpdfsetup = token.create'tagpdfsetup'

local lbrace, rbrace = token.new(string.byte'{', 1), token.new(string.byte'}', 2)

local function escape_name(name)
  return name
end

local function escape_string(str)
  return str
end

local ltx
local function get_ltx()
  ltx = _ENV.ltx
  if not ltx then
    tex.error("LaTeX PDF support not loaded", {"Maybe try adding \\DocumentMetadata."})
    ltx = {pdf = {object_id = function() return 0 end}}
  end
  function get_ltx()
    return ltx
  end
  return get_ltx()
end

-- a function to retrieve the object number of the mathml NS.
local mathml_ns_obj
local function get_mathml_ns_obj()
  mathml_ns_obj = get_ltx().pdf.object_id'tag/NS/mathml'
  if not mathml_ns_obj then
    tex.error("Failed to find MathML namespace", {"The PDF support does not know the mathml namespace"})
    mathml_ns_obj = 0
  end
  function get_mathml_ns_obj()
    return mathml_ns_obj
  end
  return get_mathml_ns_obj()
end

local function get_struct_num_next()
  get_struct_num_next = get_ltx().tag.get_struct_num_next
  return get_struct_num_next()
end

-- a function to create and manage PDF MathML attributes. This is PDF 2.0 specific
local attribute_counter = 0
local attributes = setmetatable({}, {__index = function(t, k)
  attribute_counter = attribute_counter + 1
  local attr_name = string.format('luamml_attr_%i', attribute_counter)
  t[k] = attr_name
  tex.runtoks(function()
    tex.sprint(-2, tagpdfsetup, lbrace, 'newattribute=', lbrace, attr_name, rbrace, lbrace, '/O/NSO/NS ', mathml_ns_obj or get_mathml_ns_obj(), ' 0 R')
    tex.cprint(12, k, rbrace, rbrace)
  end)
  return attr_name
end})

-- the mc-(luatex)-attributes of tagpdf
local mc_type = luatexbase.attributes.g__tag_mc_type_attr
local mc_cnt = luatexbase.attributes.g__tag_mc_cnt_attr


local stash_cnt = 0
local attrs = {}
local function write_elem(tree, stash)
  if tree[':struct'] then
    return tex.runtoks(function()
      return tex.sprint(-2, struct_use, lbrace, tree[':struct'], rbrace)
    end)
  end
  if tree[':structnum'] then
    return tex.runtoks(function()
      return tex.sprint(-2, struct_use_num, lbrace, tree[':structnum'], rbrace)
    end)
  end
  if not tree[0] then print('ERR', require'inspect'(tree)) end
  local i = 0
  for attr, val in next, tree do
    if type(attr) == 'string' and not string.find(attr, ':') and attr ~= 'xmlns' then
     i = i + 1
     attrs[i] = string.format('/%s(%s)', escape_name(attr), escape_string(val))
    end
  end
  table.sort(attrs)

  if stash then
    tree[':structnum'] = get_struct_num_next()
    stash = ', stash'
  end

  local attr_flag = i ~= 0 and ', attribute=' .. attributes[table.concat(attrs)]
  tex.sprint(-2, struct_begin, lbrace, 'tag=', tree[0], '/mathml') -- 'tag=mo/mathml' is supported syntax
  if stash then tex.sprint(-2, stash) end
  if attr_flag then tex.sprint(-2, attr_flag) end
  tex.sprint(rbrace)
  for j = 1, i do attrs[j] = nil end

  if tree[':nodes'] then
    local n = tree[':nodes']
    tex.runtoks(function()
    -- luamml-convert sets :actual on some nodes in delim_to_table and acc_to_table.
      if tree[':actual'] then
        tex.sprint(-2, mc_begin, lbrace, 'tag=Span,actualtext=')
        tex.cprint(12, tree[':actual'], rbrace)
      else
        tex.sprint(-2, mc_begin, lbrace, 'tag=', tree[0], rbrace)
      end
      -- NOTE: This will also flush all previous sprint's... That's often annoying, but in this
      -- case actually intentional.
    end)
    local mct, mcc = tex.attribute[mc_type], tex.attribute[mc_cnt]
    for i = 1, #n do
      node.set_attribute(n[i], mc_type, mct)
      node.set_attribute(n[i], mc_cnt, mcc)
    end
    tex.runtoks(function()
      tex.sprint(mc_end)
    end)
  end
  for _, elem in ipairs(tree) do
    if type(elem) ~= 'string' then
      write_elem(elem)
    end
  end
  tex.runtoks(function()
    tex.sprint(struct_end)
  end)
end

return function(element, stash)
  return write_elem(element, stash)
end
