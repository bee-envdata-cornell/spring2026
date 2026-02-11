# Homework 1
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This is the repository for Homework 1 for [BEE 4850](https://viveks.me/simulation-data-analysis).

## Learning Objectives

After completing this lab, students will be able to:

- identify spurious correlations;
- simulate from data-generating models corresponding to hypotheses about data;
- reason about the consistency of data with hypotheses about data generating processes.


## Repository Overview

The repository consists of the following files:

- `hw01.ipynb`: Jupyter Notebook for the homework assignment. Students should create code or Markdown blocks as necessary to answer questions, or can write their code and solutions in a different file format. 
- `Project.toml`, `Manifest.toml`: Julia environment files. These should just work, but feel free to add other packages as needed using the `Pkg` package manager. 
- `hw01.qmd`: Source file for Jupyter notebook generation. You could modify this file to write your solution if you want to use [Quarto](https://quarto.org/).
- `LICENSE`: This material is licensed using the MIT license. You can ignore this for working on the problem set.
- `README.md`: This file. You shouldn't need to touch this.
- `.gitignore`: This tells `git` what files to ignore. You shouldn't need to touch this.

## Prerequisites

These are the prerequisites for using the Julia package environment and the notebook. If using a different language (in a modified version of the notebook or elsewhere), the steps will be different.

1. [Install Julia](https://julialang.org/downloads/) before beginning this lab. This notebook was developed with version 1.10.4, but any 1.10.x should work (there could be some issues with other versions, depending on what's changed).
2. If necessary, [install git](https://happygitwithr.com/install-git.html) and [create a GitHub account](https://github.com). 
3. [Clone the repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository). I recommend doing this in a dedicated `BEE4850/` folder, which can also house homework assignment repositories and lecture notes. You can clone directly into the `BEE4850/` folder.   For Windows (or from another graphical interface), just create a `BEE4850` folder, then a `hw` folder inside of that, then clone into that folder. Or to clone into a `BEE4850/hw` folder, from a command prompt:
    ```bash
    cd BEE4850/
    mkdir hw
    cd hw/
    git clone https://github.com/BEE4850/hw01.git
    ```

## Opening The Notebook

1. To interact (view and run) the notebook, there are two options:
  - Install an integrated development environment, or IDE (I recommend [VS Code](https://code.visualstudio.com/) with the [Julia extension](https://marketplace.visualstudio.com/items?itemName=julialang.language-julia)). 
  - Use the [`IJulia.jl` package](https://github.com/JuliaLang/IJulia.jl). I've included this in the project environment (discussed below), so no further steps are needed.  
2. Opening the notebook will depend on what you decided to do in the previous step. 
  - If you installed VS Code, you should be able to just open `hw01.ipynb` and everything should just work. 
  - If you're using a different IDE, Google how to make sure that it is set up to run a Julia notebook.
  - If you want to use `IJulia.jl`, open a Julia prompt. You can do this by:
    - Using the `Julia-1.10` or equivalent graphical program, type `cd("BEE4850/hw")` or whatever path points to your lab notebook folder;
    - Navigating to your `BEE4850/hw/hw01` folder and typing `julia` to open the prompt.Then:
    
      ```julia
      import Pkg
      Pkg.activate(".")
      using IJulia
      notebook()
      ```
      and you can navigate to and open `hw01.ipynb`.
