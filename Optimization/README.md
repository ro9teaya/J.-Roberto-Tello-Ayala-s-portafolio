This folder contains optimization related scripts. 

The Matlab code was used to find the global minima of Easom's function: https://www.sfu.ca/~ssurjano/easom.html. 
mRC1 is an implementation of a Trust-region Method using the Cauchy Point.
mRC2 is an mplementation of a Trust-region Method using Powell's Dog Leg.
The rest of the Matlab files are helper functions for both of this methods and for plotting the graph of the desired function.

For a quick overview of this algorithms: https://optimization.mccormick.northwestern.edu/index.php/Trust-region_methods

The pyhton file chebyshevpuntos.py computes the Chebyshev Center of a set of points using the Projected Gradient Method.
Chebyshev Centers: https://handwiki.org/wiki/Chebyshev_center
Projected Gradient Algorithm: https://angms.science/doc/CVX/CVX_PGD.pdf

To run any of the files contained in this folder please use an IDE.
