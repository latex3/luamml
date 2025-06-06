# generated files

## luamml.sty

* for lualatex

## luamml-pdf.sty: 

*for pdflatex, currently mostly ignores, requirements of use unclear

# lua-files

## luamml-tex.lua
* Docu: 80%
* required by luamml.sty. 
* defines the main TeX commands
* installs the callback
* requires:
    * `local mlist_to_mml = require'luamml-convert'`: the functions to convert an mlist to mathml. 
    * `local mappings = require'luamml-legacy-mappings'`: mappings for oms, omx, oml 
    * `local write_xml = require'luamml-xmlwriter'`: function to write the xml-file????
    * `local write_struct = require'luamml-structelemwriter'`: function to write structure elements (requires tagpdf)  
    * local annotate_context = require'luamml-tex-annotate' 

## luamml-convert.lua

## luamml-legacy-mappings.lua
* Docu: ok, not more needed
* returns mapping tables for oms, omx, oml. 
* TODO: check "something fishy" comment

## luamml-xmlwriter.lua
* Docu: 90%
* returns a function that writes out the mathml-tree as xml.

## luamml-structelemwriter.lua

## luamml-tex-annotate.lua
* Docu: ok
* provides the annotate functions.

## luamml-table.lua
* Docu : 80%
* returns various table related functions, loaded by luamml-amsmath and luamml-array.
* adds a callback to hpack_filter.
* contains the functions that add the :equation-label intent to equations.
* TODO: why does it load luamml-xmlwriter, luamml-convert and luamml-tex??

## luamml-amsmath.lua  
* Docu 40%
* defines special lua functions used for the various amsmath environments.
* TODO: error handling. 

## luamml-array.lua   
* Docu: 90%
* defines lua functions used in array.sty to tag an array.
* TODO: why does it load luamml-files, error handling.

## luamml-data-combining.lua 
* Docu: ok. 
* returns table that maps combining chars to other unicode chars, 
* used by luamml-convert.lua as remap_comb

## luamml-data-stretchy.lua  
* Docu: ok
* a table containing unicode points for stretchy chars. 
* used by luamml-convert as stretchy.
 
## luamml-lr.lua               

* returns the function to_unicode. 
* TODO:
   * FIXME: Coordinate constant with tagpdf ??
   * whatsits nodes
   * CHECK: Everything else can probably be ignored, otherwise shout at me

# other styles

## luamml-demo.sty

This file demonstrates some core functionality. Some commands require the pdfmanagement or tagpdf.

* lualatex
* options 
    * tracing: sets \tracingmathml to 2, this activates the writing of the mathml into the log-file. --> luamml-tex.lua
    * files: it sets `\luamml_set_filename:n` and so writes every formula in a file `\jobname-formula-<number>.xml`
    * l3build: it sets `\luamml_set_filename:n` to `\jobname.mml` and calls `\luamml_begin_single_file:` and so writes all formula into one file. 
    * structelem: this calls `\luamml_structelem:` and so creates structure elements.
     This requires tagpdf, so at least `\DocumentMetadata{testphase=phase-I}`.
     
* commands
    * `\LuaMMLSetFilename` =  `\luamml_set_filename:n`, a simple copy
    * `\LuaMMLTagAF`: demonstrates how a associated file can be attached on the fly to a formula. This uses the function `\luamml_get_last_mathml_stream:e` (defined in luamml-tex.lua) that writes the last result (stored in the (local) variable `mlist_result`) as PDF stream and returns the object number. The tagging used in the command is rather crude and clashes (probably) with the math tagging, but as demo, it is ok and interesting.
    * `\AnnotateFormula` simple wrapper around `\luamml_annotate:en` 
    * `\WriteoutFormula` simple wrapper around `\luamml_pdf_write:`  
    
## luamml-pdf-demo.sty

This is the counterpart for pdflatex, but it demonstrates nothing and only defines the
simple wrappers `\LuaMMLSetFilename`, `\AnnotateFormula`, `\WriteoutFormula.
