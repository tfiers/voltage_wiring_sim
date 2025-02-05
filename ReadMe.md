# Voltage-to-wiring, the simulation

*In-vivo* connectomics — mapping the wires between neurons based on [voltage imaging](https://www.youtube.com/watch?v=FryqOCMyByA&t=20s) recordings.  
Proof of concept simulation.

For rendered notebooks with results:
> [![Button saying "go to website"](https://img.shields.io/badge/🚀_go_to_website-blue)](https://tfiers.github.io/phd)


## Organization

Directories:
- [`nb/`](nb) contains Jupyter Notebooks, with exploratory and figure-producing code. These notebooks are both in Python, 
  and later – from 2022 onwards – in Julia. They call code that has been factored out to external packages:
- [`pkg/`](pkg) contains Julia packages, which define functions and data types that are reused in multiple notebooks.
- [`web/`](web) contains config and code to build the [website](https://tfiers.github.io/phd) 
  where the notebooks are hosted (using [JupyterBook](https://jupyterbook.org/)).
- [`sysimg/`](sysimg) contains instructions for building a custom Julia [system image](https://julialang.github.io/PackageCompiler.jl/dev/sysimages.html). It is not necessary to run the notebooks, but it speeds up package imports and first function calls.


Files:
- [`Project.toml`](Project.toml) lists the identifiers of the Julia packages our code directly depends on.  
- `Manifest.toml` records the exact versions of all packages used to generate the results (i.e. the notebook outputs).  
- `gen_manifest.jl` is used to generate a new `Manifest.toml`.
  It is only to be used when working on this codebase; not when you want to reproduce the results.


## Reproducing results

### Julia

To reproduce results, *i.e.* to succesfully run one of the notebooks:

1. You need a version of Julia `∈ [1.7, 2)`.  
  [Download](https://julialang.org/downloads/) and run an installer for your OS if needed.

2. <details><summary>
   Download this repository. 
  
   `git clone` this repository's url with the `--recurse-submodules` option,  
   and `cd` into the new directory.
   </summary>

   `--recurse-submodules` makes sure that the git submodules 
   in this repository (see [`pkg/`](pkg/)) are cloned as well.
   </details>

3. <details><summary>
   Choose a Julia notebook to run.
  
   If it is one of the newest notebooks, the rest of this step can be skipped.  
   If not, copy the hash of the last commit to the notebook file, and `git checkout` this commit.
   </summary>

   - A link to this commit and its hash can be found on GitHub,
     in the [`nb/`](nb/) directory, next to the notebook's filename.  
     Or use `git log <path>`.
   - Why is this step needed?
     The codebase that is called from the notebook will have been further developed 
     since the notebook was last run. Checking out the commit restores the codebase 
     to its former, working state for the notebook.
    </details>

4. <details><summary>
   Install dependencies.
  
   In the root directory, enter Julia [Pkg mode](https://docs.julialang.org/en/v1/stdlib/REPL/#Pkg-mode).  
   Then run `activate .` (note the dot) and `instantiate`.  
   This might need a shell with admin access.
   </summary>
   
   - `instantiate` installs the exact package versions specified in `Manifest.toml`, 
     which is included in the repository for the purpose of reproducibility.
   - Downloading and installing all these packages will take a while.
   - If you want to instead use newer versions of dependencies (maybe because you
     already have them downloaded), run `julia gen_manifest.jl` in the terminal.
   </details>

5. <details><summary>
   Start a Jupyter server.
   </summary>
   
   - If you do not have Jupyter installed,
     run `using IJulia` and `notebook()` in the julia REPL.
   - If you have, the usual `jupyter notebook` (or `python -m notebook`)
     in the terminal works.
   </details>

You should now be able to run all cells in the notebook.

_Last time these instructions were tested on a fresh system:_ [a few weeks before today, March 2<sup>nd</sup> 2022].


### Python

Check out the following version of this repository and this ReadMe  
for instructions on how to reproduce the older, Python notebooks:  
> 👉 [Repository @ commit `56bc7f6` (Jan 8, 2022)](https://github.com/tfiers/phd/tree/56bc7f6)



### Using the Python package `pkg/pyplotlib` in Julia

- Activate your conda environment. Install matplotlib in it.
- `pip install -e pkg/pyplotlib`
- Add an environment variable `JULIA_PYTHONCALL_EXE`, pointing to the
  python executable of your active conda env (which can be found using
  `which python`). Example value: `C:\Users\tfiers\mambaforge\python`.
