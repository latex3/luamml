# Nested Math and luamml

In various places commands use nested (typically in a `\hbox`) when building formulas.
This here describes how luamml handles this, and strategies to get the wanted result.

Note: typically most examples generate also some -INNER variants in the MathML but this is not shown here, only the relevant final MathML.

## lonely box in \mathop crashes

https://github.com/latex3/luamml/issues/6

This happens only if structure element are written.
~~~~
\DocumentMetadata{uncompress,tagging=on,tagging-setup={math/setup=mathml-SE}}
\documentclass{article}
\usepackage{unicode-math}
\begin{document}
$\mathop{\hbox{$lim$}}$
\end{document}
~~~~

## simple hbox

~~~~
$ x = \hbox{$123$} $
~~~~

### MathML:

~~~~
<math xmlns="http://www.w3.org/1998/Math/MathML">
 <mi>𝑥</mi>
 <mo lspace="0.278em" rspace="0.278em">=</mo>
 <mtext>
 <math xmlns="http://www.w3.org/1998/Math/MathML">
 <mn>
 123
 </mn>
 </math>
 </mtext>
</math>
~~~~

Notes: internal math element and unwanted mtext.

### Structure:

~~~~
  <Formula>
    <math>
     <mn>
      23
     </mn>
    </math>
    <math>
     <mi>x</mi>
     <mo>=</mo>
     <mtext>
      <math>
       <mn>1</mn>
      </math>
     </mtext>
    </math>
   </Formula>
~~~~   

Notes: a second <math> element which contains a part (?) of the hbox content.
Internal math element and unwanted mtext too.

## simple hbox with suppressed math collection

~~~~
$ x = \hbox{\m@th$123$} $
$ x = \hbox{\MathCollectFalse$123$} $
$ x = \hbox{$\m@th123$} $
~~~~

Makes no difference (more or less expected, as math collection is already suppressed inside math).

## luamml_ignore:

~~~~
$ x = \hbox{\luamml_ignore:$123$} $
$ x = \hbox{$\luamml_ignore:123$} $
$ x = {\luamml_ignore: \hbox{$123$}} $
~~~~

### MathML

~~~~
<math xmlns="http://www.w3.org/1998/Math/MathML">
 <mi>𝑥</mi>
 <mo lspace="0.278em" rspace="0.278em">=</mo>
 <mtext>
 123
 </mtext>
</math>
~~~~

Notes: unwanted math gone, wanted mo too, unwanted mtext still there.

### Structure

~~~~
 <Formula>
    123
    <math>
     <mi>x</mi>
     <mo>=</mo>
     <mtext>
     </mtext>
    </math>
   </Formula>
~~~~   

Notes: unwanted math gone, wanted mo too, unwanted mtext still there. Content 123 is outside of the structure.

## Annotation with consume_label

~~~~
$ x = \luamml_annotate:en
     {nucleus=true,core=consume_label('box')}
     {\hbox{$123\luamml_save:n{box}$}} $
~~~~

### MathML

~~~~
<math xmlns="http://www.w3.org/1998/Math/MathML">
 <mi>𝑥</mi>
 <mo lspace="0.278em" rspace="0">=</mo>
 <mn>
 123
 </mn>
</math>
~~~~

Notes: Looks ok.     

### Structure Element

~~~~
  <Formula>
    <math>
     <mi>x</mi>
     <mo>=</mo>
     <mn>
      123
     </mn>
    </math>
   </Formula>
~~~~

Looks ok too.      

## Additional group ...

~~~~
$ x = {
        \luamml_annotate:en
        {nucleus=true,core=consume_label('box')}
        {\hbox{$123\luamml_save:n{box}$}}
      } $
~~~~     

### MathML


~~~~
<math xmlns="http://www.w3.org/1998/Math/MathML">
 <mi>𝑥</mi>
 <mo lspace="0.278em" rspace="0.278em">=</mo>
 <mtext>
 <mn>
 123
 </mn>
 </mtext>
</math>
~~~~

Notes: unwanted mtext appears ...
Same happens with the structure element.

**TODO** How to get rid of that?? It disappears if there is something else in the group, but what is safe? 


### Nesting

Nesting requires that nucleus=true is set

~~~~
\newcommand\somesymbol[1]{\luamml_annotate:en
        {nucleus=true,core=consume_label('box')}
        {\hbox{$#1\luamml_save:n{box}$}}}
$ x = \somesymbol{a}^{\somesymbol{b}} $
~~~~

still surrounds the inner symbol with a mtext.

~~~~
<math xmlns="http://www.w3.org/1998/Math/MathML">
 <mi>𝑥</mi>
 <mo lspace="0.278em" rspace="0.278em">=</mo>
 <msup>
 <mi>𝑎</mi>
 <mtext>
 <mi>𝑏</mi>
 </mtext>
 </msup>
</math>
~~~~


Using unique labels does not help. 

~~~~
\newcommand\somesymbol[1]{\luamml_annotate:en
        {nucleus=true,core=consume_label('box#1')}
        {\hbox{$#1\luamml_save:n{box#1}$}}}
$ x = \somesymbol{a}^{\somesymbol{b}} $
~~~~ 

**TODO**: how can symbols be annotated that are used as superscripts? Real world example: how can `\boldsymbol` be made tagging aware?   