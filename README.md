# Recovery of planted hitting sets for hypergraphs

This code and data repository accompanies the paper

- Planted Hitting Set Recovery in Hypergraphs. Ilya Amburg, Jon Kleinberg and Austin R. Benson [ arXiv:1905.05839](https://arxiv.org/abs/1905.05839), 2019.

All of the code is written in Julia 1.0.

For questions, please email Ilya at ia244@cornell.edu.

### Data

These files were downloaded directly from [here](http://www.cs.cornell.edu/~arb/data/.html). The Avocado email dataset is available from https://catalog.ldc.upenn.edu/LDC2015T03, but we cannot include the data directly due to the usage terms.

### Setup

First download the code:

```bash
git clone https://github.com/ilyaamburg/Hypergraph-Planted-Hitting-Set-Recovery.git
```

The code is written in Julia 1.0. To reproduce everything, you will need the following packages:

```julia
using Pkg
Pkg.add("Arpack")
Pkg.add("Combinatorics")
Pkg.add("FileIO")
Pkg.add("JLD2")
Pkg.add("MatrixNetworks")
Pkg.add("PyPlot")
Pkg.add("StatsBase")
```


### Reproduce the figures and tables in the paper

The three separate folders contain code for getting results from each of the three types of datasets we used, namely emails, tags, and conferences.

- Emails

The file "resultsEmail.jl" produces the results for each of the three email datasets, namely Enron, Avocado, and WC3 while "emailPlots.jl" produces the corresponding figures.

- Tags

The file "resultsTags.jl" produces the results for the Ubuntu and Math tags datasets. The code is designed to randomly sample tags every time. The explicit random instance presented in the paper is found in files of the form "tags-dataset-rank-used-tags.txt". Here each entry represents the tag number used.

- Conferences

The file "resultsConf.jl" produces the results for the DBLP database. The code is designed to randomly sample conferences every time. The explicit random instance presented in the paper is found in files of the form "confs-DBLP-rank-used-tags.txt". Here each pair is in the format (Conference, Year).
