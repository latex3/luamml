# generated files

## luamml.sty

* for lualatex

## luamml-pdf.sty: 

*for pdflatex, currently mostly ignores, requirements of use unclear

# lua-files

## luamml-tex.lua

* required by luamml.sty. 
* defines the main TeX commands
* requires:
    * `local mlist_to_mml = require'luamml-convert'`: the functions to convert an mlist to mathml. 
    * `local mappings = require'luamml-legacy-mappings'`: ??????  
    * `local write_xml = require'luamml-xmlwriter'`: function to write the xml-file????
    * `local write_struct = require'luamml-structelemwriter'`: function to write structure elements (requires tagpdf)  

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
    