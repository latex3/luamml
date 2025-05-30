# luamml annotations

luamml creates a mathml represention of TeX formula by adding a callback to the mlist_to_hlist callback.

It is possible to *annotate* parts of a formula to change the output. The following gives some details about how it works.

## Two output modes

luamml has two output modes: 
 *it can write the mathml into a file (the „xml-writer“), and 
 * it can write the mathml as structure elements into the PDF (with the „structelem-writer“) -- the later requires tagpdf but we assume here anyway that the tagging code is loaded. 

## General syntax

~~~~
\luamml_annote:en {<options>}{content}
~~~~

## Storing of annotations

Annotations are stored in the properties of a node. If the option
`nucleus` is used (true) in the nucleus of the noad. If the content consists
of more than one noad the last one store the annotation (this can be changed with the option offset), the other noads are marked with an empty/false property. 

## Annotations with the xml-writer

### Test 1
~~~~
$\luamml_annotate:en{}{a^3b^2}$
$\luamml_annotate:en{nucleus=true}{a^3b^2}$
~~~~

Result for both:

~~~~
 <msup>
 <mi>𝑏</mi>
 <mn>2</mn>
 </msup>
~~~~

### Test 2
~~~~
$\luamml_annotate:en{core=false}{a^3b^2}$
$\luamml_annotate:en{nucleus=true,core=false}{a^3b^2}$
~~~~
 
Result for both: empty math

~~~~
<math xmlns="http://www.w3.org/1998/Math/MathML"/>
~~~ 

### Test 3

If a core is given is should always contain a `[0]` entry, 
beside this, it can contain a list of attribute.

~~~~
$\luamml_annotate:en{core={[0]='duck',intent='quack',blub='blub'}}{a^3b^2}$
~~~~

Result

~~~~
<duck blub="blub" intent="quack"/>
~~~~

Here one starts to see the first difference if nucleus is set. Now the second exponent is kept:

~~~~
$\luamml_annotate:en
 {nucleus=true,core={[0]='duck',
   intent='quack',blub='blub'}}
 {a^3b^2}$
~~~~

~~~~
 <msup>
 <duck blub="blub" intent="quack"/>
 <mn>2</mn>
 </msup>
~~~~

If an offset is used then the first exponent is retained:

~~~~
$\luamml_annotate:en
 {nucleus=true,offset=1,
   core={[0]='duck',intent='quack',blub='blub'}}
 {a^3b^2}$
~~~~


Result:

~~~~
 <msup>
 <duck blub="blub" intent="quack"/>
 <mn>3</mn>
 </msup>
~~~~

### Test 4

   
