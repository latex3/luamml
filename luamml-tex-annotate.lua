--[[
   This file defines the luafunctions
   * \__luamml_annotate_begin: 
   * \__luamml_annotate_end:we
   * \__luamml_annotate_end:e
   
   It defines the global function
   * consume_label 
   
   It returns
   * mark_environment: a table with annotation data used as _ENV
   
   Core function is 
   * annotate (used in the luafunctions)
   
   TODO: should annotate() error if there are no noads in the argument?     
--]]

local nest = tex.nest

local properties = node.get_properties_table()

local mark_environment = {
  data = {
  },
}
do
  local _ENV = mark_environment
  function consume_label(label, fn)
    local mathml = data.mathml[label]
    data.mathml[label] = nil
    if fn then fn(mathml) end
    return mathml
  end
end

--[[
     The function annotate receives a "key-val"-list as arguments.
     It stores a table (annotation) in the properties of a node.
     And knows the following "keys"      
      * nucleus, boolean: decides if the annotation is stored 
        in a noad or the nucleus of a noad. 
        The noad is a wrapper around the inner kernel noad which contains the class 
        \mathbin, \mathord, etc., the superscript, subscript, ....
        So by e.g. replacing the noad with an annotation all of this gets replaced, while 
        replacing the nucleus only replaces the main math expression 
        (which is often what you want). 
        For more complicated math structures (e.g. square roots) on the other hand 
        annotations should usually affect the whole noad and not just 
        the nucleus (which would be e.g. 2 in \sqrt{2}.
      * offset, 0< int <= noad count: decides on which noad the annotation is stored.  
      * core, table or false: contains the mathml representation, either directly, or through
        one (or more?) consume_label.
        See luamml-algorithm.tex for examples how the core table should look like.
        Stored as `mathml_core` in the annotation. 
      * struct, string: a label referencing a stashed, labeled structure.
        Stored as a function mathml_filter, that adds the field :struct to the mathml. 
      * structnum, number: a structure number referencing a stashed structure.
        Stored as a function mathml_filter, that adds the field :structnum to the mathml.
        TODO: are they (and mathml_filter) actually used somewhere? 
      See luamml-convert.lua for the processing.
--]]

local function annotate()
  local annotation, err = load( 'return {'
      .. token.scan_argument()
    .. '}', nil, 't', mark_environment)
  if not annotation then
    tex.error('Error while parsing LuaMML annotation', {err})
    return 0
  end
  annotation = annotation()
  local nesting = nest.top
  local props = properties[nesting.head]
  -- `luamml__annotate_context` is initialized below in `__luamml_annotate_begin:`
  -- and has two (optional) fields:
  -- `head` contains a pointer to the tail of current list. 
  -- `prev` contains data of previous annotate commands in the same list.
  local current = props and props.luamml__annotate_context
  if current then
    current, props.luamml__annotate_context = current.head, current.prev
  else
    tex.error('Mismatched LuaMML annotation',
      {'Something odd happened. Maybe you forgot braces around an annotated symbol in a subscript or superscript?'})
    return 0
  end
  local after = nesting.tail
  local count, offset = 0, annotation.offset
  local marked
  -- TODO should this error or silently return? 
  if current == after then
    tex.error'Empty LuaMML annotation'
  else
    repeat
      current = current.next
      count = count + 1
      if count == offset then
        marked = current
      elseif offset or current ~= after then
        local props = properties[current]
        if not props then
          props = {}
          properties[current] = props
        end
        props.mathml_table, props.mathml_core = nil, false
      end
    until current == after
    if offset and not marked then
      tex.error'Invalid offset in LuaMML annotation'
    end
    marked = marked or current
    if annotation.nucleus then
      marked = marked.nucleus
    end
    if marked then
      local props = properties[marked]
      if not props then
        props = {}
        properties[marked] = props
      end
      if annotation.core ~= nil then
        props.mathml_core = annotation.core
      end
      if annotation.struct ~= nil then
        local saved = props.mathml_filter
        local struct = annotation.struct
        function props.mathml_filter(mml, core)
          mml[':struct'] = struct
          if saved then
            return saved(mml, core)
          else
            return mml, core
          end
        end
      end
      if annotation.structnum ~= nil then
        local saved = props.mathml_filter
        local structnum = annotation.structnum
        function props.mathml_filter(mml, core)
          mml[':structnum'] = structnum
          if saved then
            return saved(mml, core)
          else
            return mml, core
          end
        end
      end            
    else
      tex.error'Unable to annotate nucleus of node without nucleus'
    end
  end
  return count
end

--[[ Documentation for luafunction \__luamml_annotate_begin:
     This function initialize an annotation.
     It stores in the properties of head of the current list
     the current tail node and previous annotate context of previous
     annotations in the same list.
--]]

local funcid = luatexbase.new_luafunction'__luamml_annotate_begin:'
token.set_lua('__luamml_annotate_begin:', funcid, 'protected')
lua.get_functions_table()[funcid] = function()
  local top = nest.top
  local temp = top.head
  local props = properties[temp]
  if not props then
    props = {}
    properties[temp] = props
  end
  props.luamml__annotate_context = {
    prev = props.luamml__annotate_context,
    head = top.tail,
  }
end

--[[ Documentation for luafunction \__luamml_annotate_end:we
     This function calls annotate(). Additionally it compares
     its first argument (a number) with the count of noads done by
     annotate(). With luatex this is not really needed and only a source
     of errors, so the next function should be preferred.
--]]

funcid = luatexbase.new_luafunction'__luamml_annotate_end:we'
token.set_lua('__luamml_annotate_end:we', funcid, 'protected')
lua.get_functions_table()[funcid] = function()
  local count = token.scan_int()
  local real_count = annotate()
  if count ~= real_count then
    tex.error('Incorrect count in LuaMML annotation', {
        'A LuaMML annotation was discovered with an explicit count \z
        which was not the same as the number of top-level nodes annotated.',
        string.format('This can be fixed by changing the supplied count from %i to %i \z
          or by omitting the count value entirely.', count, real_count)
    })
  end
end

--[[ Documentation for luafunction \__luamml_annotate_end:e
     This function calls annotate(). 
--]]

funcid = luatexbase.new_luafunction'__luamml_annotate_end:e'
token.set_lua('__luamml_annotate_end:e', funcid, 'protected')
lua.get_functions_table()[funcid] = annotate


return mark_environment
