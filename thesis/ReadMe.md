
## How to compile

`git clone` with the `--recurse-submodules` option,
so that the dependency ['totex'](https://github.com/tfiers/totex) is included.

[Installed][1] [`TinyTeX-1`][2] with:
```
wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh
```
[1]: https://yihui.org/tinytex/#installation
[2]: https://github.com/rstudio/tinytex-releases

Then install these extra packages in addition to the included ones: \
`$ tlmgr install --with-doc cm-super silence printlen capt-of ltablex relsize xurl chngcntr texdoc pgfplots memoir textcase pdfpages placeins caption microtype multirow makecell siunitx pdflscape biblatex biber bookmark cleveref newunicodechar palatino mathpazo listings lstaddons xpatch`

(In git bash for Windows: `tlmgr.bat`, instead).

<!-- Then: `xelatex main.tex` (note, `xelatex`, not `xetex`) -->

<!-- For continous compilation: `latexmk -pvc -pdfxe main.tex`. -->

Then run, for continuous compilation: `latexmk -pvc -pdf main.tex`.

On font-related errors, running `updmap` might help.

<!-- This caption fix is no longer necessary as of at least june '24 -->
<!-- To fix internal links to sidecaptions not working (and instead sending you to top of document), see https://gitlab.com/axelsommerfeldt/caption/-/issues/175#note_1549762142
I.e. I manually replaced `C:\tools\TinyTeX\texmf-dist\tex\latex\caption\caption-memoir.sto`
with https://gitlab.com/axelsommerfeldt/caption/-/blob/eb364ba/tex/caption-memoir.sto -->

A manual patch to a used latex package:
- Replace three `&` by `:` in `C:\tools\TinyTeX\texmf-dist\tex\latex\lstaddons\lstlinebgrd.sty`.
  (Thanks [this comment](https://tex.stackexchange.com/questions/451532/recent-issues-with-lstlinebgrd-package-with-listings-after-the-latters-updates#comment1281207_451538))
