## Dip-means clustering package v.0.1 ##

**Dip-means package** is a Matlab implementation of the *dip-means clustering method*, which is an incremental clustering approach that provides a partition of a dataset and an estimation of the number of the underlying data clusters.

Written by Argyris Kalogeratos <http://www.cs.uoi.gr/~akaloger>. Release date for package version 0.1: August 2013. For any comments contact the author at <argyriskalogeratos[at)gmail[onedot}com>. See also the package page <http://www.cs.uoi.gr/~akaloger/matterial/dip-means/> for future improvements/releases.

Copyright (C) 2012-2013, Argyris Kalogeratos. License details can be found in the respective section at the end of this document.

----------

### Contents ###

1. Description
2. Requirements
3. Dependencies and third-party components
4. Installation and Testing
5. How to cite this work
6. License
7. Thanks
8. References


### 1. Description ###

Learning the number of clusters is a key problem in data clustering. Dip-means  [1] is a robust incremental method to learn the number of data clusters that can be used as a wrapper around any iterative clustering algorithm of k-means family. In contrast to many popular methods which make assumptions about the underlying cluster distributions, dip-means only assumes a fundamental cluster property: each cluster to admit a *unimodal distribution*. The proposed algorithm considers each cluster member as an individual ‘viewer’ and applies a univariate statistic hypothesis test for unimodality (dip-test) on the distribution of distances between the viewer and the cluster members. Important advantages are:

- the unimodality test is applied on univariate distance vectors, 
- it can be directly applied with kernel-based methods, since only the pairwise distances are involved in the computations. 

See also a presentation poster in [2].

**This package is a Matlab implementation of dip-means clustering method [1]**, while it redistributes, unaltered or with minor adaptations/changes, code for *Gaussian k-means method* (*g-means*) [3], *x-means* [4], and the computation of dip-statistic, that were already available online. For details on the third-party components see the respective section.


### 2. Requirements ###

The implementation has been tested on Matlab R2011b 64bit (713.0.564) and newer versions of the platform.


### 3. Dependencies and third-party components ###
    
`./xmeans/*`

> The x-means method that uses the Bayesian Information Criterion (BIC). Unfortunately, there is no information about the original source for this piece of code (any hints?). However, the code has been checked and reviewed for correctness.

`./gmeans/*` 

> The Gaussian k-means (g-means) method that uses the Anderson-Darling statistic in the second file. Source: Coda Analyzer v0.2 <http://www.lab.upc.edu/software/codas/index.html>.

`hartigansdiptestdemo.m`

> A demonstration script for the dip statistic. Creates some obviously unimodal and bimodal Gaussian distributions just to show what dip statistic does. Written by Nic Price.

`HartigansDipSignifTest.m` and `HartigansDipTest.m`

> Calculates Hartigans' dip statistic and its significance for an empirical pdf (vector of sample values). Written by F. Mechler.

`./var/*`

> This folder contains various utility routines, some of which have been written by other authors.


### 4. Installation and Testing ###

No special installation is needed. Run `init.m` first to setup the paths and to open the basic files one needs:

- `bistest.m`: the main file that provides a demonstration of the whole package. It opens a data file and executes some algorithms.
- `./bisecting/bisect_kmeans.m`: the function of bisecting-based k-means. Takes various parameters, some of them in a structure. it is a wrapper around all splitting algorithms.
- `bisect.m`: this performs a cluster split according to a splitting algorithm.
- `test_unimodal_cluster.m`: it is the main function used by `bisect_kmeans.m` to check for cluster unimodality as described by dip-means.
- `HartigansDipSignifTest.m`: this applies the dip-test on a vector with empirical observations (empirical pdf).

**Important note**: the code assumes that the input data matrix contains row-vectors. More info is provided by the inline description of each code file. 

So, to test the code do first the initialization with `init.m` and then run `bistest.m`. The two available datasets that come with this package are:

- `iris.mat`: the well-known IRIS dataset form the UCI Machine Learning Repository <http://archive.ics.uci.edu/ml/datasets/Iris>.
- `combo_setting.mat`: a combo 2d dataset used for the experiments in the paper [1]. The dataset contains multiple structures of different geometrical properties that are generally well-separated in space.


### 5. How to cite this work ###

You may directly cite the paper [1] using the following *bibtex* file <http://www.cs.uoi.gr/~akaloger/files/MyPapers/dipmeans.bib>.


### 6. License ###

Copyright (C) 2012-2013, Argyris Kalogeratos. Dip-means package v.0.1 is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
     
Dip-means package v.0.1 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
     
You should have received a copy of the GNU General Public License along with this software in the file LICENSE.txt. If not, see <http://www.gnu.org/licenses/>.
    
Brief overview of the GNU GPL:

- Provides copyright protection: **True**
- Can be used in commercial applications: **True**
- Bug fixes / extensions must be released to the public domain: **True**
- Provides an explicit patent license: **False**
- Can be used in proprietary (closed source) applications: **False**
- Is a viral license: **True**

Other resources for the license:

- A quick guide to GPLv3: <https://www.gnu.org/licenses/quick-guide-gplv3.html>.
- Full text of GPLv3: <https://www.gnu.org/licenses/gpl-3.0.html>.


### 7. Thanks ###

Special thanks to Prof. Aristidis Likas for his useful comments and support in the development of this package. Moreover, the author should also thank those contributed to any of the third-party components that were used and are redistributed by this package.


### 8. References ###

[1] Argyris Kalogeratos and Aristidis Likas, *Dip-means: an incremental clustering method for estimating the number of clusters*, In Proceedings of the 26th Conference on Neural Information Processing Systems (NIPS), 2012. <http://www.cs.uoi.gr/~akaloger/files/MyPapers/dip-meansNIPS2012.pdf>.

[2] Argyris Kalogeratos and Aristidis Likas, *Dip-means poster presentation*, NIPS 2012. <http://www.cs.uoi.gr/~akaloger/files/MyPosters/dip_means_NIPS2012_poster.pdf>.

[3] Dan Pelleg and Andrew Moore, *X-means: Extending k-means with efficient estimation of the number of clusters*. In Proceedings of the 17th International Conference on Machine Learning, 2000.

[4] Greg Hamerly and Charles Elkan, *Learning the k in k-means*. In Proceedings of the 17th Conference on Neural Information Processing Systems (NIPS), 2003.
