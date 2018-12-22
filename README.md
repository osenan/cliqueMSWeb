# cliqueMS Web

This code contains the Shiny App for cliqueMS package.

## Installation

CliqueMS Web does not require any instalation.

If you have R packages `cliqueMS` and `shiny` installed launch

```R

shiny::runGitHub("cliqueMSWeb","osenan")
```

To use cliqueMS Web locally.

## Tutorial

### Introduction

CliqueMS Web annotates processed LC/MS data. It provides annotation
for isotopes, ion-adducts and fragmentation adducts.
The web application is based on `cliqueMS` package functions.
As in the package, CliqueMS Web analyses samples individually,
however, if you need to annotate a large amount of samples,
it is recommended to use the R package version.

### Step 1: Uploading spectral data files

The first step for CliqueMS Web is that you upload your spectral data
in two formats, raw and processed by XCMS. The processed data is
needed to provide the feature list. In addition, CliqueMS Web requires
profile data. For memory optimization, processed xcms objects `xcmsSet`
do no contain complete profile data. That is why you need to upload
the raw data.

You can use the spectral example data for practise:

![](./FigsTutorial/example.png)

Once the spectral data is uploaded you the Annotation button will be
activated. Now it is time to set the annotation parameters.

### Step 2: Set annotation parmeters

#### Clique parameters

CliqueMS Web uses a network-based algorithm to group features that are
likely to belong to the same metabolite. These groups correspond to
cliques (fully connected components) in a network created from the
spectral data. As there are many clique configurations, cliqueMS uses
a probabilistic model to find the clique groups with the maximum log-likelihood.
CliqueMS Web will try several clique groups until the log-likelihood cannot
be increased or until this increment is very small.

The `tol` parameter sets the minimum relative increase in log-likelihood.

![](./FigsTutorial/tol.png)

#### Isotope parameters