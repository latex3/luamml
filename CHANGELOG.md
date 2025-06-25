# Changelog
All notable changes to the `luamml` package since the
2025-02-17 will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
this project uses date-based 'snapshot' version identifiers.

## [2025-06-25]
 ### Fixed
  * luamml-amsmath.lua: logic in debug_mtable
  * Add support for subscripts and superscripts on accent nodes
  * Refactor structure element number assignment for labels in tables,
    avoiding double free in nested math.
  
 ### Changed
  * Disable LuaTeX's math flattening by default
  * improved documentation
  
 ### Added
  * Added \luamml_attribute:nnn to associate MathML attributes with math items.

## [2025-03-06]

 * Fix missing characters when hyphenation appears (GH #11)
 * Fix inverted stretch flag for horizontal accents (GH tagging-project#855)
 - Ulrike Fischer, 2025-03-06
 * add class attribute to math environments
 * correct columnalign (take label column into account)
 * add intent :continued-row in split enviroment
 * add intent :system-of-equations to environments
 * temporary patch to \common@align@ending to store the environment name
 * start some debugging functions (variable debugmtable)
 * correct columnspacing
 * add intent :pause-medium between columns
  
## 2025-02-21

- Ulrike Fischer, 2025-02-21
  * change intent :equationlabel to :equation-label and 
  :noequationlabel to :no-equation-label
  

## 2025-02-17

### Changed
- Ulrike Fischer, 2025-02-17
  * moved all patches into latex-lab
  * added sockets to luamml.dtx
  * changed handling of tags/labels: empty tags produces a row too and have an intent
  * corrected small bugs 

- Ulrike Fischer, 2024-11-29
  luamml-structelemwriter.lua: moved the actualtext for e.g. stretched braces from the structure element to the mc-chunk.

- Ulrike Fischer, 2024-03-03
  luamml.dtx: add plug for mbox socket to correctly annotate them in math.

- Ulrike Fischer, 2024-11-29
  luamml-structelemwriter.lua: use structnum instead of label when stashing. 
