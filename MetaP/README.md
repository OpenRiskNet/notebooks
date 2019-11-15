# OpenRiskNet MetaP case study notebook

The *som_prediction* Jupyter Notebook demonstrates the combination of four OpenRiskNet
services focusing on the prediction of possible Site-Of-Metabolism in small molecular
compounds. These are:

* [SMARTCyp](https://smartcyp.sund.ku.dk/mol_to_som): CYP540 reactivity-based SOM prediction.
* Structure-based SOM prediction using docking.
* [FAME3](https://nerdd.zbh.uni-hamburg.de/fame3/): phase I and II SOM prediction.
* [MetPred](https://metpred.service.pharmb.io/draw/): SOM and reaction type prediction.

## Installation requirements

Primary use of the OpenRiskNet services only requires the Python `requests` library for
communication with the services.

For data visualisation, this demonstration notebook uses: 

* The Python `pandas` library to combine and display the output of the services as data tables.
* The `RDKit` cheminformatics software to generate 2D depictions of the molecules and highlight
  the predicted SOMs on the structure.
  
The `RDKit` software may not be the most straightforward to install. As alternative we offer the
*som_prediction* Notebook as fully operational [Binder](https://github.com/MD-Studio/MDStudio_SMARTCyp) 
service. By clicking the `launch binder` button the service will launch the notebook in your
browser for you to interact with.
If you prefer to install `RDKit` on your own infrastructure we recommend using the [Anaconda](https://anaconda.org)
package manager available for Linux, OSX and Windows.
