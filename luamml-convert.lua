local remap_comb = require'luamml-data-combining'
local stretchy = require'luamml-data-stretchy'
local to_text = require'luamml-lr'

local properties = node.get_properties_table()

local hlist_t, kern_t, glue_t, rule_t = node.id'hlist', node.id'kern', node.id'glue', node.id'rule'

local noad_t, accent_t, style_t, choice_t = node.id'noad', node.id'accent', node.id'style', node.id'choice'
local radical_t, fraction_t, fence_t = node.id'radical', node.id'fraction', node.id'fence'

local math_char_t, sub_box_t, sub_mlist_t = node.id'math_char', node.id'sub_box', node.id'sub_mlist'

local function invert_table(t)
  local t_inv = {}
  for k, v in next, t do
    t_inv[v] = k
  end
  return t_inv
end

local noad_names = node.subtypes'noad'

--[[ We could determine the noad subtypes dynamically:
local noad_sub = invert_table(noad_names)
local noad_ord = noad_sub.ord
local noad_op = noad_sub.opdisplaylimits
local noad_oplimits = noad_sub.oplimits
local noad_opnolimits = noad_sub.opnolimits
local noad_bin = noad_sub.bin
local noad_rel = noad_sub.rel
local noad_open = noad_sub.open
local noad_close = noad_sub.close
local noad_punct = noad_sub.punct
local noad_inner = noad_sub.inner
local noad_under = noad_sub.under
local noad_over = noad_sub.over
local noad_vcenter = noad_sub.vcenter
-- But the spacing table depends on their specific values anyway, so we just verify the values
]]
local noad_ord, noad_op, noad_oplimits, noad_opnolimits = 0, 1, 2, 3
local noad_bin, noad_rel, noad_open, noad_close, noad_punct = 4, 5, 6, 7, 8
local noad_inner, noad_under, noad_over, noad_vcenter = 9, 10, 11, 12

for i, n in ipairs{'ord', 'opdisplaylimits', 'oplimits', 'opnolimits', 'bin',
    'rel', 'open', 'close', 'punct', 'inner', 'under', 'over', 'vcenter'} do
  assert(noad_names[i-1] == n)
end
-- Attention, the spacing_table is indexed by subtype+1 since 1-based tables are faster in Lua
local spacing_table = {
  {0        , '0.167em', '0.167em', '0.167em', '0.222em', '0.278em', 0        , 0        , 0        , '0.167em', 0        , 0        , 0        , },
  {'0.167em', '0.167em', '0.167em', '0.167em', nil      , '0.278em', 0        , 0        , 0        , '0.167em', '0.167em', '0.167em', '0.167em', },
  nil,
  nil,
  {'0.222em', '0.222em', '0.222em', '0.222em', nil      , nil      , '0.222em', nil      , nil      , '0.222em', '0.222em', '0.222em', '0.222em', },
  {'0.278em', '0.278em', '0.278em', '0.278em', nil      , 0        , '0.278em', 0        , 0        , '0.278em', '0.278em', '0.278em', '0.278em', },
  {0        , 0        , 0        , 0        , nil      , 0        , 0        , 0        , 0        , 0        , 0        , 0        , 0        , },
  {0        , '0.167em', '0.167em', '0.167em', '0.222em', '0.278em', 0        , 0        , 0        , '0.167em', 0        , 0        , 0        , },
  {'0.167em', '0.167em', '0.167em', '0.167em', nil      , '0.167em', '0.167em', '0.167em', '0.167em', '0.167em', '0.167em', '0.167em', '0.167em', },
  {'0.167em', '0.167em', '0.167em', '0.167em', '0.222em', '0.278em', '0.167em', 0        , '0.167em', '0.167em', '0.167em', '0.167em', '0.167em', },
  nil,
  nil,
  nil,
}
local spacing_table_script = {
  {0        , '0.167em', '0.167em', '0.167em', 0        , 0        , 0        , 0        , 0        , 0        , 0        , 0        , 0        , },
  {'0.167em', '0.167em', '0.167em', '0.167em', nil      , 0        , 0        , 0        , 0        , 0        , '0.167em', '0.167em', '0.167em', },
  nil,
  nil,
  {0        , 0        , 0        , 0        , nil      , nil      , 0        , nil      , nil      , 0        , 0        , 0        , 0        , },
  {0        , 0        , 0        , 0        , nil      , 0        , 0        , 0        , 0        , 0        , 0        , 0        , 0        , },
  {0        , 0        , 0        , 0        , nil      , 0        , 0        , 0        , 0        , 0        , 0        , 0        , 0        , },
  {0        , '0.167em', '0.167em', '0.167em', 0        , 0        , 0        , 0        , 0        , 0        , 0        , 0        , 0        , },
  {0        , 0        , 0        , 0        , nil      , 0        , 0        , 0        , 0        , 0        , 0        , 0        , 0        , },
  {0        , '0.167em', '0.167em', '0.167em', 0        , 0        , 0        , 0        , 0        , 0        , 0        , 0        , 0        , },
  nil,
  nil,
  nil,
}
do -- Fill the blanks
  local st, sts = spacing_table, spacing_table_script

  local st_op, sts_op = st[noad_op+1], sts[noad_op+1]
  st[noad_oplimits+1], sts[noad_oplimits+1] = st_op, sts_op
  st[noad_opnolimits+1], sts[noad_opnolimits+1] = st_op, sts_op

  local st_ord, sts_ord = st[noad_ord+1], sts[noad_ord+1]
  st[noad_under+1], sts[noad_under+1] = st_ord, sts_ord
  st[noad_over+1], sts[noad_over+1] = st_ord, sts_ord
  st[noad_vcenter+1], sts[noad_vcenter+1] = st_ord, sts_ord
end


local radical_sub = node.subtypes'radical'
local fence_sub = node.subtypes'fence'

local remap_lookup = setmetatable({}, {__index = function(t, k)
  local ch = utf8.char(k & 0x1FFFFF)
  t[k] = ch
  return ch
end})
local digit_map = {["0"] = true, ["1"] = true,
     ["2"] = true, ["3"] = true, ["4"] = true,
     ["5"] = true, ["6"] = true, ["7"] = true,
     ["8"] = true, ["9"] = true,}

-- Two marker tables. They are used instead of an embellished operator to mark space-like or user provided constructs
local user_provided, space_like = {}, {}

local nodes_to_table

local function sub_style(s) return s//4*2+5 end
local function sup_style(s) return s//4*2+4+s%2 end

-- The _to_table functions generally return a second argument which is
-- could be (if it were a <mo>) a core operator of the embellishe operator
-- or space_like/user_provided
-- acc_to_table is special since it's return value should
-- always be considered a core operator

-- We ignore large_... since they aren't used for modern fonts
local function delim_to_table(delim)
  if not delim then return end
  local props = properties[delim]
  local mathml_table = props and props.mathml_table
  if mathml_table then return mathml_table end
  local mathml_filter = props and props.mathml_filter -- Kind of pointless since the arguments are literals, but present for consistency
  local char = delim.small_char
  if char == 0 then
    local result = {[0] = 'mspace', width = string.format("%.3fpt", tex.nulldelimiterspace/65781.76)}
    if mathml_filter then
      return mathml_filter(result, space_like)
    else
      return result, space_like
    end
  else
    local fam = delim.small_fam
    char = remap_lookup[fam << 21 | char]
    local result = {[0] = 'mo', char, ['tex:family'] = fam ~= 0 and fam or nil, stretchy = not stretchy[char] or nil, lspace = 0, rspace = 0, [':node'] = delim }
    if mathml_filter then
      return mathml_filter(result, result)
    else
      return result, result
    end
  end
end

-- Like kernel_to_table but always a math_char_t. Also creating a mo and potentially remapping to handle combining chars.
-- No lspace or space is set here since these never appear as core operators in an mrow.
local function acc_to_table(acc, cur_style, stretch)
  if not acc then return end
  local props = properties[acc]
  local mathml_table = props and props.mathml_table
  if mathml_table then return mathml_table end
  if acc.id ~= math_char_t then
    error'confusion'
  end
  local mathml_filter = props and props.mathml_filter -- Kind of pointless since the arguments are literals, but present for consistency
  local fam = acc.fam
  local char = remap_lookup[fam << 21 | acc.char]
  char = remap_comb[char] or char
  if stretch ~= not stretchy[char] then -- Handle nil gracefully in stretchy
    stretch = nil
  end
  local result = {[0] = 'mo', char, ['tex:family'] = fam ~= 0 and fam or nil, stretchy = stretch, [':node'] = acc}
  if mathml_filter then
    return mathml_filter(result)
  else
    return result
  end
end

local function kernel_to_table(kernel, cur_style)
  if not kernel then return end
  local props = properties[kernel]
  local mathml_table = props and props.mathml_table
  if mathml_table then return mathml_table, user_provided end
  local mathml_filter = props and props.mathml_filter -- Kind of pointless since the arguments are literals, but present for consistency
  local id = kernel.id
  if id == math_char_t then
    local fam = kernel.fam
    local char = remap_lookup[fam << 21 | kernel.char]
    local elem = digit_map[char] and 'mn' or 'mi'
    local result = {[0] = elem,
      char,
      ['tex:family'] = fam ~= 0 and fam or nil,
      mathvariant = utf8.len(char) == 1 and elem == 'mi' and utf8.codepoint(char) < 0x10000 and 'normal' or nil,
      [':node'] = kernel,
    }
    if mathml_filter then
      return mathml_filter(result, result)
    else
      return result, result
    end
  elseif id == sub_box_t then
    local result
    if kernel.list.id == hlist_t then -- We directly give up for vlists
      result = to_text(kernel.list.head)
    else
      result = {[0] = 'mi', {[0] = 'mglyph', ['tex:box'] = kernel.list, [':node'] = kernel}}
    end
    if mathml_filter then
      return mathml_filter(result, result)
    else
      return result, result
    end
  elseif id == sub_mlist_t then
    if mathml_filter then
      return mathml_filter(nodes_to_table(kernel.list, cur_style))
    else
      return nodes_to_table(kernel.list, cur_style)
    end
  else
    error'confusion'
  end
end

local function do_sub_sup(t, core, n, cur_style)
  local sub = kernel_to_table(n.sub, sub_style(cur_style))
  local sup = kernel_to_table(n.sup, sup_style(cur_style))
  if sub then
    if sup then
      return {[0] = 'msubsup', t, sub, sup}, core
    else
      return {[0] = 'msub', t, sub}, core
    end
  elseif sup then
    return {[0] = 'msup', t, sup}, core
  else
    return t, core
  end
end


-- If we encounter a . or , after a number, test if it's followed by another number and in that case convert it into a mn
local function maybe_to_mn(noad, core)
  if noad.sub or noad.sup then return end
  local after = noad.next
  if not after then return end
  if after.id ~= noad_t then return end
  if after.subtype ~= noad_ord then return end
  after = after.nucleus
  if not after then return end
  if after.id ~= math_char_t then return end
  if not digit_map[remap_lookup[after.fam << 21 | after.char]] then return end
  core[0] = 'mn'
end

local function noad_to_table(noad, sub, cur_style, mn)
  local nucleus, core = kernel_to_table(noad.nucleus, sub == noad_over and cur_style//2*2+1 or cur_style)
  if sub == noad_ord then
    if core and core[0] == 'mo' then
      core[0] = 'mi'
      core.mathvariant = #core == 1 and type(core[0]) == 'string' and utf8.len(core[0]) == 1 and utf8.codepoint(core[0]) < -0x10000 and 'normal' or nil
      core['tex:class'], core.stretchy, core.lspace, core.rspace = nil
    end
    if nucleus == core and #core == 1 then
      if mn and core[0] == 'mi' and (core[1] == '.' or core[1] == ',') and maybe_to_mn(noad, core) or core[0] == 'mn' then
        if mn then
          mn[#mn+1] = core[1]
          nucleus = do_sub_sup(mn, mn, noad, cur_style)
          if nucleus == mn then
            return nil, mn, mn
          else
            return nucleus, mn, false
          end
        elseif not noad.sub and not noad.sup then
          return core, core, core
        end
      end
    end
  elseif sub == noad_op or sub == noad_oplimits or sub == noad_opnolimits or sub == noad_bin or sub == noad_rel or sub == noad_open
      or sub == noad_close or sub == noad_punct or sub == noad_inner then
    if not core or not core[0] then
      -- TODO
    else
      core[0] = 'mo'
      if stretchy[core[1]] then core.stretchy = false end
      if core.mathvariant == 'normal' then core.mathvariant = nil end
      core.lspace, core.rspace = 0, 0
    end
    nucleus['tex:class'] = noad_names[sub]

    if (noad.sup or noad.sub) and (sub == noad_op or sub == noad_oplimits) then
      nucleus.movablelimits = sub == noad_op
      local sub = kernel_to_table(noad.sub, sub_style(cur_style))
      local sup = kernel_to_table(noad.sup, sup_style(cur_style))
      return {[0] = sup and (sub and 'munderover' or 'mover') or 'munder',
        nucleus,
        sub or sup,
        sub and sup,
      }, core
    end
  elseif sub == noad_under then
    return {[0] = 'munder',
      nucleus,
      {[0] = 'mo', '_',},
    }, core
  elseif sub == noad_over then
    return {[0] = 'mover',
      nucleus,
      {[0] = 'mo', '\u{203E}',},
    }, core
  elseif sub == noad_vcenter then -- Ignored. Nucleus will need special handling anyway
  else
    error[[confusion]]
  end
  return do_sub_sup(nucleus, core, noad, cur_style)
end

local function accent_to_table(accent, sub, cur_style)
  local nucleus, core = kernel_to_table(accent.nucleus, cur_style//2*2+1)
  local top_acc = acc_to_table(accent.accent, cur_style, sub & 1 == 1)
  local bot_acc = acc_to_table(accent.bot_accent, cur_style, sub & 2 == 2)
  return {[0] = top_acc and (bot_acc and 'munderover' or 'mover') or 'munder',
    nucleus,
    bot_acc or top_acc,
    bot_acc and top_acc,
  }, core
end

local style_table = {
  display = {displaystyle = "true", scriptlevel = "0"},
  text = {displaystyle = "false", scriptlevel = "0"},
  script = {displaystyle = "false", scriptlevel = "1"},
  scriptscript = {displaystyle = "false", scriptlevel = "2"},
}

style_table.crampeddisplay, style_table.crampedtext,
style_table.crampedscript, style_table.crampedscriptscript = 
  style_table.display, style_table.text,
  style_table.script, style_table.scriptscript

local function radical_to_table(radical, sub, cur_style)
  local kind = radical_sub[sub]
  local nucleus, core = kernel_to_table(radical.nucleus, cur_style//2*2+1)
  local left = delim_to_table(radical.left)
  local elem
  if kind == 'radical' or kind == 'uradical' then
    -- FIXME: Check that this is really a square root
    elem, core = {[0] = 'msqrt', nucleus, }, nil
  elseif kind == 'uroot' then
    -- FIXME: Check that this is really a root
    elem, core = {[0] = 'msqrt', nucleus, kernel_to_table(radical.degree)}, nil
  elseif kind == 'uunderdelimiter' then
    elem, core = {[0] = 'munder', left, nucleus}, left
  elseif kind == 'uoverdelimiter' then
    elem, core = {[0] = 'mover', left, nucleus}, left
  elseif kind == 'udelimiterunder' then
    elem = {[0] = 'munder', nucleus, left}
  elseif kind == 'udelimiterover' then
    elem = {[0] = 'mover', nucleus, left}
  else
    error[[confusion]]
  end
  return do_sub_sup(elem, core, radical, cur_style)
end

local function fraction_to_table(fraction, sub, cur_style)
  local num, core = kernel_to_table(fraction.num, cur_style + 2 - cur_style//6*2)
  local denom = kernel_to_table(fraction.denom, cur_style//2*2 + 3 - cur_style//6*2)
  local left = delim_to_table(fraction.left)
  local right = delim_to_table(fraction.right)
  local mfrac = {[0] = 'mfrac',
    linethickness = fraction.width and fraction.width == 0 and 0 or nil,
    bevelled = fraction.middle and "true" or nil,
    num,
    denom,
  }
  if left then
    return {[0] = 'mrow',
      left,
      mfrac,
      right, -- might be nil
    }
  elseif right then
    return {[0] = 'mrow',
      mfrac,
      right,
    }
  else
    return mfrac, core
  end
end

local function fence_to_table(fence, sub, cur_style)
  local delim, core = delim_to_table(fence.delim)
  if delim[0] == 'mo' then
    delim.fence = 'true'
  end
  return delim, core
end

local function space_to_table(amount, sub, cur_style)
  if amount == 0 then return end
  if sub == 99 then -- TODO magic number
    -- 18*2^16=1179648
    return {[0] = 'mspace', width = string.format("%.3fem", amount/1179648)}, space_like
  else
    -- 65781.76=tex.sp'100bp'/100
    return {[0] = 'mspace', width = string.format("%.3fpt", amount/65781.76)}, space_like
  end
end

local running_length = -1073741824
local function rule_to_table(rule, sub, cur_style)
  local width = string.format("%.3fpt", rule.width/65781.76)
  local height = rule.height
  if height == running_length then
    height = '0.8em'
  else
    height = height
  end
  local depth = rule.depth
  if depth == running_length then
    depth = '0.2em'
  else
    depth = depth
  end
  return {[0] = 'mspace', mathbackground = 'currentColor', width = width, height = height, depth = depth}, space_like
end

-- The only part which changes the nodelist, we are converting bin into ord
-- nodes in the same way TeX would do it later anyway.
local function cleanup_mathbin(head)
  local last = 'open' -- last sub if id was noad_t, left fence acts fakes being a open noad, bin are themselves. Every other noad is ord
  for n, id, sub in node.traverse(head) do
    if id == noad_t then
      if sub == noad_bin then
        if node.is_node(last) or last == noad_opdisplaylimits
            or last == noad_oplimits or last == noad_opnolimits
            or last == noad_rel or last == noad_open or last == noad_punct then
          n.subtype, last = noad_ord, noad_ord
        else
          last = n
        end
      else
        if (sub == noad_rel or sub == noad_close or sub == noad_punct)
            and node.is_node(last) then
          last.subtype = noad_ord
        end
        last = sub
      end
    elseif id == fence_t then
      if sub == fence_sub.left then
        last = noad_open
      else
        if node.is_node(last) then
          last.subtype = noad_ord, noad_ord
        end
        last = noad_ord
      end
    elseif id == fraction_t or id == radical_t or id == accent_t then
      last = noad_ord
    end
  end
  if node.is_node(last) then
    last.subtype = noad_ord
  end
end

function nodes_to_table(head, cur_style)
  cleanup_mathbin(head)
  local t = {[0] = 'mrow'}
  local result = t
  local nonscript
  local core, last_noad, last_core, mn = space_like, nil, nil, nil
  for n, id, sub in node.traverse(head) do
    local new_core, new_mn, new_node, new_noad
    local props = properties[n]
    local mathml_table = props and props.mathml_table
    if mathml_table then
      new_node, new_core = mathml_table, user_provided
    elseif id == noad_t then
      local new_n
      new_n, new_core, new_mn = noad_to_table(n, sub, cur_style, mn)
      if new_mn == false then
        t[#t], new_mn = new_n, nil
      else
        new_node = new_n -- might be nil
      end
      new_noad = sub
    elseif id == accent_t then
      new_node, new_core = accent_to_table(n, sub, cur_style)
      new_noad = noad_ord
    elseif id == style_t then
      if sub ~= cur_style then
        if #t == 0 then
          t[0] = 'mstyle'
        else
          local new_t = {[0] = 'mstyle'}
          t[#t+1] = new_t
          t = new_t
        end
        if sub < 2 then
          t.displaystyle, t.scriptlevel = true, 0
        else
          t.displaystyle, t.scriptlevel = false, sub//2 - 1
        end
        cur_style = sub
      end
      new_core = space_like
    elseif id == choice_t then
      local size = cur_style//2
      new_node, new_core = nodes_to_table(n[size == 0 and 'display'
                                        or size == 1 and 'text'
                                        or size == 2 and 'script'
                                        or size == 3 and 'scriptscript'
                                        or assert(false)], 2*size), space_like
    elseif id == radical_t then
      new_node, new_core = radical_to_table(n, sub, cur_style)
      new_noad = noad_ord
    elseif id == fraction_t then
      new_node, new_core = fraction_to_table(n, sub, cur_style)
      new_noad = noad_inner
    elseif id == fence_t then
      new_node, new_core = fence_to_table(n, sub, cur_style)
      local class = n.class
      new_noad = class >= 0 and class or sub == fence_sub.left and noad_open or noad_close
    elseif id == kern_t then
      if not nonscript then
        new_node, new_core = space_to_table(n.kern, sub, cur_style)
      end
    elseif id == glue_t then
      if cur_style >= 4 or not nonscript then
        if sub == 98 then -- TODO magic number
          nonscript = true
        else
          new_node, new_core = space_to_table(n.width, sub, cur_style)
        end
      end
    elseif id == rule_t then
      new_node, new_core = rule_to_table(n, sub, cur_style)
    -- elseif id == disc_t then -- Uncommon, does not play nicely with math mode and no sensible mapping anyway
    end -- The other possible ids are whatsit, penalty, adjust, ins, mark. Ignore them.
    nonscript = nil
    if core and new_core ~= space_like then
      core = core == space_like and new_core or nil
    end
    if new_node then
      if new_noad then
        local space = last_noad and (cur_style >= 4 and spacing_table_script or spacing_table)[last_noad + 1][new_noad + 1] or 0
        if assert(space) ~= 0 then
          if new_core and new_core[0] == 'mo' then
            new_core.lspace = space
          elseif last_core and last_core[0] == 'mo' then
            last_core.rspace = space
          else
            t[#t+1] = {[0] = 'mspace', width = space} -- TODO Move into operators whenever possible
          end
        end
        last_noad, last_core = new_noad, new_core
      elseif new_node[0] ~= 'mspace' or new_node.mathbackground then
        last_core = nil
      end
      t[#t+1] = new_node
    end
    mn = new_mn
  end
  -- In TeX, groups are never space like
  if core == space_like then
    core = {[0] = 'mi', intent = '@ignore'}
    result[#result+1] = core
  end
  if t[0] == 'mrow' and #t == 1 then
    assert(t == result)
    result = t[1]
  end
  local mathml_filter = props and props.mathml_filter
  if mathml_filter then
    return mathml_filter(result, core)
  else
    return result, core
  end
end

local function register_remap(family, mapping)
  family = family << 21
  for from, to in next, mapping do
    remap_lookup[family | from] = utf8.char(to)
  end
end

local function to_math(root, style)
  if root[0] == 'mrow' then
    root[0] = 'math'
  else
    root = {[0] = 'math', root}
  end
  root.xmlns = 'http://www.w3.org/1998/Math/MathML'
  root['xmlns:tex'] = 'http://typesetting.eu/2021/LuaMathML'
  if style < 2 then
    root.display = 'block'
  end
  return root
end

return {
  register_family = register_remap,
  process = function(head, style) return nodes_to_table(head, style or 2) end,
  make_root = to_math,
}
