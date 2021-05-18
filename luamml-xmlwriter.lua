-- FIXME: Not sure yet if this will be needed
local function escape_name(name)
  return name
end

local escapes = {
  ['"'] = "&quot;",
  ['<'] = "&lt;",
  ['>'] = "&gt;",
  ['&'] = "&amp;",
}
local function escape_text(text)
  return string.gsub(tostring(text), '("<>&)', escapes)
end

local attrs = {}
local function write_elem(tree, indent)
  if not tree[0] then print('ERR', require'inspect'(tree)) end
  local escaped_name = escape_name(assert(tree[0]))
  local i = 0
  for attr, val in next, tree do if type(attr) == 'string' and string.byte(attr) ~= 0x3A then
    i = i + 1
    attrs[i] = string.format(' %s="%s"', escape_name(attr), escape_text(val))
  end end
  table.sort(attrs)
  local out = string.format('%s<%s%s', indent or '', escaped_name, table.concat(attrs))
  for j = 1, i do attrs[j] = nil end
  if not tree[1] then
    return out .. '/>'
  end
  out = out .. '>'
  local inner_indent = indent and indent .. '  '
  for _, elem in ipairs(tree) do
    if type(elem) == 'string' then
      if inner_indent then
        out = out .. inner_indent
      end
      out = out .. escape_text(elem)
    else
      out = out .. write_elem(elem, inner_indent)
    end
  end
  if indent then out = out .. indent end
  return out .. '</' .. escaped_name .. '>'
end

return function(element, indent, version)
  return (version == '11' and '<?xml version="1.1"?>' or '') ..
    write_elem(element, indent and '\n' or nil)
end
