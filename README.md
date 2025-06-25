# LuaMML: Automated LuaLaTeX math to MathML conversion
This is an attempt to implement automatic conversion of LuaLaTeX inline and display math expressions into MathML code to aid with tagging.
It works best with `unicode-math`, but it can also be used with traditional math fonts if mappings to Unicode are provided.

## Installation
Run `l3build install` to install `luamml` into your local `texmf` tree.

## Usage
To generate MathML of your LuaLaTeX formulas you should use latex-lab-math which will internally call LuaMML. A typical example would be

```
\DocumentMetadata{lang=en, tagging=on, tagging-setup={math/setup=mathml-SE}}
\documentclass{article}
\usepackage{unicode-math}
\begin{document}
\[ E=mc^2 \]
\end{document}
```

This will automatically generate MathML nd embed it into the tagging structure
of the output.
See the latex-lab-math documentation for details.

## License
LuaMML may be modified and distributed under the terms of the [LaTeX Project Public License](https://www.latex-project.org/lppl/), version 1.3c or greater.
It is written by Marcel Krüger and the LaTeX Project Team.

<!-- Also see a [`tagpdf` experiment using this to tag PDF formulas](https://github.com/u-fischer/tagpdf/blob/develop/experiments/exp-mathml-lua.tex). -->

<!-- If you are very brave you can also try running `pdflatex test_pdf` and afterwards run `./pdfmml.lua test_pdf.lua` to get pdflatex formulas converted. -->
