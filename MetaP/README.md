# OpenRiskNet MetaP case study notebook

The *som_prediction* Jupyter Notebook demonstrates the combination of four OpenRiskNet
services focusing on the prediction of possible Site-Of-Metabolism (SOM)s in small molecular
compounds. These are:

* [SMARTCyp](https://smartcyp.sund.ku.dk/mol_to_som): CYP540 reactivity-based SOM prediction.
* Structure-based SOM prediction using docking.
* [FAME3](https://nerdd.zbh.uni-hamburg.de/fame3/): phase I and II SOM prediction.
* [MetPred](https://metpred.service.pharmb.io/draw/): SOM and reaction type prediction.

## Quick start

Can't wait to try it out? Click the `launch binder` button, this will start a fully operational 
[Binder](https://mybinder.org) service in your browser for you to play
with.

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/OpenRiskNet/notebooks/master?filepath=MetaP)


## Installation requirements

Primary use of the OpenRiskNet services only requires the Python `requests` library for
communication with the services.

For data visualisation, this demonstration notebook uses: 

* The Python `pandas` library to combine and display the output of the services as data tables.
* The `RDKit` cheminformatics software to generate 2D depictions of the molecules and highlight
  the predicted SOMs on the structure.
  
The `RDKit` software may not be the most straightforward to install. The alternative is to use the
Binder service described in the Quick Start.
If you prefer to install `RDKit` on your own infrastructure we recommend using the [Anaconda](https://anaconda.org)
package manager available for Linux, OSX and Windows.
