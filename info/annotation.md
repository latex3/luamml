# luamml annotations

luamml creates a mathml represention of TeX formula by adding a callback to the mlist_to_hlist callback.

It is possible to *annotate* parts of a formula to change the output. The following gives some details about how it works.

Note: node/noad are not used consistently or correctly everywhere. And examples using
ducks are not serious math.

## Two output modes

luamml has two output modes: 
 * it can write the mathml into a file (the „xml-writer“), and 
 * it can write the mathml as structure elements into the PDF (with the „structelem-writer“). This requires tagpdf but we assume here anyway that the tagging code is loaded. 

## General syntax

~~~~
\luamml_annote:en {<options>}{<content>}
~~~~

<options> is a key-val argument. <content> some (nearly) arbitrary part of a formula.
As annotions are stored in the properties of a node/noad <content> can not be empty,
but it doesn't need to be char, but can be e.g. `\latelua{}` (see latex-lab-mathintent).

TODO: decide if empty <content> should error or warn or quit silently.

## Storing of annotations

Annotations are stored in the properties of a node. If the option
`nucleus` is used (set to `true`), the the annotation is stored in the nucleus node of the noad. If the <content> consists
of more than one noad the last one is used to store the annotation (this can be changed with the option offset), the other noads are marked with an empty/false property, so luamml knows that they are part of the (one) annotation. 

## Annotations with the xml-writer

The annotation removes the content and replaces it by something given through the options.

### No core 

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

### core=false
~~~~
$\luamml_annotate:en{core=false}{a^3b^2}$
$\luamml_annotate:en{nucleus=true,core=false}{a^3b^2}$
~~~~
 
Result for both: empty math

~~~~
<math xmlns="http://www.w3.org/1998/Math/MathML"/>
~~~ 

### core with options

If a core is given is should always contain a `[0]` entry for the root of xml-tree, 
beside this, it can contain a list of attributes and more childs for the tree.

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

If `offset` is set  is used then the first exponent is retained:

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

### core with content

The core can contain a string, that adds new content:

~~~~
$\luamml_annotate:en{core={[0]='duck','ente'}}{a^3b^2}$
~~~~

gives

~~~~
<duck>ente</duck>
~~~~

If `nucleus` is set, then one gets the expected

~~~~
 <duck>ente</duck>
 <mn>2</mn>
~~~~

Special (xml) chars are escaped:

~~~~
$\luamml_annotate:en{core={[0]='duck','<mo>ente</mo>'}}{a^3b^2}$
~~~~

gives 

~~~~
 <duck>&lt;mo&gt;ente&lt;/mo&gt;</duck>
~~~~

Which probably isn't what is wanted here. If one wants additional substructure on has to add explicit children:

~~~~
$\luamml_annotate:en
   {core={[0]='duck',
          {[0]='mo','ente'},
          {[0]='mi','pato'}}}{a^3b^2}$
~~~~

gives 

~~~~
 <duck>
 <mo>ente</mo>
 <mi>pato</mi>
 </duck>
~~~~

### Saving content and reusing it

It is possible to store the xml-tree of a formula for later use and then to "consume" this labeled math. 

~~~~
\setbox0\hbox{$a^3b^2\luamml_save:n{mylabel}$}

$\luamml_annotate:en{core={[0]='duck',consume_label('mylabel')}}{a^3b^2}$
~~~~

gives

~~~~
 <duck>
 <mrow>
 <msup>
 <mi>𝑎</mi>
 <mn>3</mn>
 </msup>
 <msup>
 <mi>𝑏</mi>
 <mn>2</mn>
 </msup>
 </mrow>
 </duck>
 ~~~~
 
 A labelled math is removed after it has been consumed. Trying to consume it a second time silently gives nothing, as does trying to use a label that doesn't exist at all. 
 It is possible to reuse the label name later, it doesn't have to be unique through the document.
 
 It is possible to consume two and more labelled math:
 
~~~~
\setbox0\hbox{$c^2\luamml_save:n{mylabelA}$}
\setbox0\hbox{$d^2\luamml_save:n{mylabelB}$}
$\luamml_annotate:en{core={[0]='duck',consume_label('mylabelA'),consume_label('mylabelB')}}{a^3b^2}$
~~~~

gives

~~~~
 <duck>
 <msup>
 <mi>𝑐</mi>
 <mn>2</mn>
 </msup>
 <msup>
 <mi>𝑑</mi>
 <mn>2</mn>
 </msup>
 </duck>
~~~~

It is also possible to use the labelled math as root for the core (but then it is difficult to add attributes):

~~~~
\setbox0\hbox{$c^2\luamml_save:n{mylabel}$}
$\luamml_annotate:en{core=consume_label('mylabel')}{a^3b^2}$
~~~~

gives 

~~~~
 <msup>
 <mi>𝑐</mi>
 <mn>2</mn>
 </msup>
~~~~

### Only top level noads are support.

According to the documentation, only „top level noads“ are annotated.
But it is not quite clear what this means.

This annotation does nothing:

~~~~
$a^3b^{\luamml_annotate:en{core={[0]='duck'}}{2}}$
~~~~

The mathml simply says `<msup><mi>𝑏</mi><mn>2</mn></msup>`.

But these annotations work:

~~~~
$a^3b^{\luamml_annotate:en{core={[0]='duck','quack'}}{\latelua{}}}$
$a^3b^{+\luamml_annotate:en{core={[0]='duck','quack'}}{2}}$
$\frac
   {\luamml_annotate:en{nucleus=true,core={[0]='duck}}{2}}}
   {5}$
~~~~

**TODO** It must be clear, when annotations are ignored and what to do to ensure that this doesn't happens.


### Challenge: the `\genfrac` command. 

The `\genfrac` command from amsmath (use by various user commands, e.g. `\binom`) basically consist of three parts: 

~~~~
1. left delimiter code:
   \left <left delimiter> some rule to set the height\right. 
2.    user content
3. right delimiter code:
   \left <right delimiter> some rule to set the height\right.
~~~~

How to annotate that to get the right mathml output?

Wanted output

~~~~
<mrow> %left/right container
 <mo>left delimiter</mo>
 mathml for content
 <mo>right delimiter</mo>
</mrow>
~~~~

If one annotates only the delimiter like this
~~~~
\luamml_annotate:en
  {core={[0]='mo','left delimiter'}}
  {left delimiter code}
user content 
\luamml_annotate:en
  {core={[0]='mo','right delimiter'}}
  {right delimiter code}
~~~~
then the surrounding `mrow` is missing.

An option is to store all three components in a box with a suitable `\luamml_save:n` and then to do 

~~~~
core={[0]='mrow', consume_label('left'),consume_label('content'),consume_label('right')}
~~~~

But this means on the TeX level that the user content is probably processed twice (unless one can reuse the box), something that is not done currently. 

**TODO**


## Structelem-writer

The structelem-writer adds tagging commands to create structure elements.

The annotation options here are much more restricted as annotated content is no longer automatically tagged. As with the xml-writer the <content> is not longer in the xml tree. The content is typeset but does not exist for luamml anymore. 

### No content

latex-lab-mathintent defines an \invisibletimes command that basically does this

~~~~
\luamml_annotate:en {core={[0]='mo',intent="times",'^^^^2062'}}
    {\latelua{}}
~~~~

In the xml-output this gives ` <mo intent="times">⁢</mo>`  with an U+2062 in the middle.

In the PDF structure this gives an empty /mo structure element with an attribute `/intent(times)`. If that is enough for mathcat, it is fine, but if an actual content item is needed, it gets complicated.
    





   
 

           


   
