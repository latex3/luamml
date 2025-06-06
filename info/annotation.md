# luamml annotations

luamml creates a MathML represention of a TeX formula by adding a callback to the `mlist_to_hlist` callback.

It is possible to *annotate* parts of a formula to change the MathML. The following gives some details about how it works and discusses open problems.

Note: node in the following can be node or noad. And examples using
ducks are not serious math.

## Two output modes

luamml has two output modes:
 * it can write the MathML into a file (the „xml-writer“), and

 * it can write the MathML as structure elements into the PDF (with the „structelem-writer“). This requires tagpdf but we assume here anyway that the tagging code is loaded.

Both output modes can be used together and share lots of code. Trying to change the one output will typically affect also the other.

## General syntax for annotations

~~~~
\luamml_annote:en {<options>}{<content>}
~~~~

<options> is a key-val argument. <content> some (nearly) arbitrary part of a formula.
As annotations are stored in the properties of a node <content> can not be empty,
but it doesn't need to be a char, but can be e.g. a whatsits node created with `\latelua{}` (see latex-lab-mathintent).

**TODO**: decide if empty <content> should error (current behaviour) or warn or quit silently.

## Storing of annotations

Annotations are stored in the properties of a node. If the option
`nucleus` is used (set to `true`), the annotation is stored in the nucleus node of the node. If the <content> consists
of more than one node the last one is used to store the annotation (this can be changed with the option `offset`), the other nodes are marked with an empty/false property, so luamml knows that they are part of the (one) annotation.

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

If an offset is set

~~~~
$\luamml_annotate:en{nucleus=true,offset=1}{a^3b^2}$
~~~~

Then the result is
~~~~
 <msup>
 <mi>𝑎</mi>
 <mn>3</mn>
 </msup>
~~~~
So the node which is marked is kept and the other thrown away.

### core=false
~~~~
$\luamml_annotate:en{core=false}{a^3b^2}$
$\luamml_annotate:en{nucleus=true,core=false}{a^3b^2}$
~~~~

Result for both: empty math

~~~~
<math xmlns="http://www.w3.org/1998/Math/MathML"/>
~~~~

### core with options

If the option `core` is given is should always contain a `[0]` entry for the root of the MathML-subtree, beside this, it can contain a list of attributes and more children for the tree.

~~~~
$\luamml_annotate:en{core={[0]='duck',intent='quack',blub='blub'}}{a^3b^2}$
~~~~

Result

~~~~
<duck blub="blub" intent="quack"/>
~~~~

Here one can see a difference if nucleus is set. Now the second exponent is kept:

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

If `offset` is set then the first exponent is retained:

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

### On the fly consumption

math does need to be saved before it's consumed, but annotations are processed at the end of the formula and `luamml_save:n` immediately when it appears, so usually consuming will always happen after saving as long as both are in the same formula. This means that when consuming a label the math often doesn't need to be saved first in a \hbox:

~~~~
$
  \luamml_annotate:en{core={[0]='duck',consume_label('mylabelA'),consume_label('mylabelB')}}
   {\hbox{$c^2\luamml_save:n{mylabelA}$} = \hbox{$d^2\luamml_save:n{mylabelB}$} }
$
~~~~

gives (note that the equal sign in the middle is gone, when structure elements are used it is marked as artifact.) 

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


### Only top level noads are supported

According to the documentation, only „top level noads“ are annotated.
But it is not quite clear what this means.

This annotation does nothing:

~~~~
$a^3b^{\luamml_annotate:en{core={[0]='duck'}}{2}}$
~~~~

The mathml simply says `<msup><mi>𝑏</mi><mn>2</mn></msup>`.

Here nucleus = true is needed to ensure that the annotation works.

The reason is a optimization in LuaTeX. If a superscript (or subscript) is a mathlist kernel noad contains exactly one noad which is a simple noad (e.g. here the 2), then the math list and the simple noad in it get optimized away and the nucleus of the simple noad directly becomes the new superscript (subscript). So b^{2} is the same as b^2. This process removes the node the annotation is placed on and therefore the annotation.

By using nucleus = true the annotation is placed on the nucleus of the noad (the 2, not the mathord noad consisting of a 2) and therefore stays when it is moved into the superscript.

Alternatively you can use \mathflattenmode=0 to disable this optimization, but that can have effects to rendering since then you have more intermediate math lists.


But these annotations work:

~~~~
$a^3b^{\luamml_annotate:en{core={[0]='duck','quack'}}{\latelua{}}}$
$a^3b^{+\luamml_annotate:en{core={[0]='duck','quack'}}{2}}$
$\frac
   {\luamml_annotate:en{nucleus=true,core={[0]='duck}}{2}}}
   {5}$
~~~~

**TODO** It must be cleared, when annotations are ignored and what to do to ensure that this doesn't happen.

Probably related: https://github.com/latex3/tagging-project/issues/859


### Challenge: the `\genfrac` command.

The `\genfrac` command from `amsmath` (use by various user commands, e.g. `\binom`) basically consist of three parts:

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

An option is to store all three components in boxes with a suitable `\luamml_save:n` and then to do

~~~~
core={[0]='mrow', consume_label('left'),consume_label('content'),consume_label('right')}
~~~~

But this means on the TeX level that the user content is probably processed twice (unless one can reuse the box), something that is not done currently.


## Structelem-writer

The options to annotate the formula are much more restricted when structure elements are created too as annotated content is no longer automatically tagged. When annotated with `\luamml_annotate:en` the nodes of the <content> are no longer referenced in the lua-table built by luamml and are not seen by the structelem-writer code. The content is only typeset.

### No visible content

latex-lab-mathintent defines an `\invisibletimes` command that basically does this

~~~~
\luamml_annotate:en {core={[0]='mo',intent="times",'^^^^2062'}}
    {\latelua{}}
~~~~

In the xml-output this gives ` <mo intent="times">⁢</mo>`  with an U+2062 in the middle.

In the PDF structure this gives an empty `mo`-structure element with an attribute `/intent(times)`. If that is enough for MathCat, it is fine, but if an actual content item is needed, it gets complicated.


### content and setting the core

When a core is set like in this example
~~~~
$x=\luamml_annotate:en{core={[0]='duck',intent='quack'}}{abc}$
~~~~
then the correct `duck` structure including the attribute is created,
but as luamml doesn't add tagging commands for the content, `abc` has the MC-attribute from the Formula structure and so gets inserted as a container at the begin of this structure. This is also the case if additionally `nucleus` is used, and then affects also exponents.

This basically means that no annotation using `core` can be used if structure elements are create too.

**TODO**  luamml should not drop the nodes when they are marked but parsed them nevertheless.


#### Inserting a stashed structure with structnum

It is possible to insert stashed structures into the MathML structure tree with the `structnum` (or `struct` key). This requires that `nucleus` is set, and that the `core` option is not used (**TODO** are the restrictions  intended?).  This allows to tag the content with the normal tagpdf commands:




~~~~
$x=
   \tag_struct_begin:n
       {
         tag=duck,
         % attribute if wanted
         stash,
       }
     \edef\mystructurenum{\tag_get:n{struct_num}}
     \tag_struct_begin:n{tag=pato}
      \tag_mc_begin:n {}
      \luamml_annotate:en
       {
         nucleus = true,
         structnum=\mystructurenum
       }
       { abc^2 }
      \tag_mc_end:
      \tagstructend
      \tag_struct_end:
   + y
$
~~~~

This will surround `abc` with the two structures.

~~~~
<msup>
  <duck>
   <pato>
    abc
   </pato>
  </duck>
  <mn>2</mn>
</msup>
~~~~

but the MathML-file will be wrong and not contain the additional structures:

~~~~
<mi>𝑥</mi>
 <mo lspace="0.278em" rspace="0.278em">=</mo>
 <msup>
 <mi>𝑐</mi>
 <mn>2</mn>
 </msup>
 <mo lspace="0.222em" rspace="0.222em">+</mo>
 <mi>𝑦</mi>
~~~~

#### Saving the math

Another option is to save the math first, then one can use as above
`consume_label` .

To avoid that the saving creates a Formula structure it should be done inside the math, use `\MathCollectFalse` outside the math does not work, probably as it triggers `\luamml_ignore:` somewhere, but this needs investigation. **TODO**

~~~~
$
\setbox0=\hbox{$abc^2\luamml_save:n{label}$}
x= \luamml_annotate:en
       {
         core={[0]='duck',intent='quack',
          consume_label('label')}
       }
       { \box0 }
   + y
$
~~~~

This has the benefit that it gives a reasonable result for both output modes. But it requires a content that can be saved.

## Consumption on-the-fly

The consumption on-the-fly demonstrated above does work too. As mentioned already the equal sign is then marks as artifact, so one has to take care that every contents is saved:

~~~~
$
  \luamml_annotate:en{core={[0]='duck',consume_label('mylabelA'),consume_label('mylabelB')}}
   {\hbox{$c^2\luamml_save:n{mylabelA}$} = \hbox{$d^2\luamml_save:n{mylabelB}$} }
$
~~~~

**TODO** test nested setups!

### The challenge `\genfrac`

Put together this means that the currently best way to get the correct tagging and xml-output with the annotate command is to save everything in boxes and then to consume the labels (nesting untested yet), so something along these lines (or a similar setup with on-the-fly consumption):

~~~~
$
\setbox0=\hbox{$(\luamml_save:n{left}$}
\setbox2=\hbox{$\frac{1}{2}\luamml_save:n{middle}$}
\setbox4=\hbox{$)\luamml_save:n{right}$}
x= \luamml_annotate:en
       {
         core={[0]='mrow',intent='binom',
          consume_label('left'),
          consume_label('middle'),
          consume_label('right')}
       }
       {\box0\box2\box4}
   + y
$
~~~~




## Manipulation without \luamml_annotate:en

`luamml_annotate` is not the only option to add intents and similar.

E.g. to move tags into a column of the equation, the socket math/display/tag/begin
puts the tag into a stashed structure, records the number and then uses that later in
the struct-elemwriter. But this requires access to the low-level code and so is not something package authors can do.

**TODO** `genfrac` should be handled better with some low-level lua code too.

## Summary

While annotating math that is written out to files works more or less, there are clear open problems if structure elements should be created.

There should be at least simple methods to
* surround math parts with `mrow` or similar without loosing the content
* add intents and other attributes.

A proof of concept would be a macro for |x| that should allow to mark it as absolute value (and should handle more complex arguments than x).

~~~~
<mrow intent = "absolute-value($x)"<
 <mo>|</mo> <mi arg="x">x</mi> <mo>|</mo>
</mrow> 
~~~~ 
