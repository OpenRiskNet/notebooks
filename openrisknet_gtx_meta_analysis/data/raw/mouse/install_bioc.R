# Install BioConductor first
source("https://bioconductor.org/biocLite.R")
biocLite()
# Install Ensemble Gene ID version of the following arrays
# Install Homo sapiens array: Affymetrix Human Genome U133 Plus 2.0 Array
install.packahes(c("http://mbni.org/customcdf/22.0.0/ensg.download/hgu133plus2hsensgcdf_22.0.0.tar.gz"));
# Install cdf package for Homo sapiens array type: Affymetrix Human Genome U133A 2.0 Array
install.packages(c("http://mbni.org/customcdf/22.0.0/ensg.download/hgu133a2hsensgcdf_22.0.0.tar.gz"));
# Install cdf package for Homo sapiens array type: Affymetrix HT HG-U133+ PM Array Plate
install.packages(c("http://mbni.org/customcdf/22.0.0/ensg.download/hthgu133pluspmhsensgcdf_22.0.0.tar.gz"))


# Install Mouse array: Affymetrix Mouse Genome 430 2.0 Array
install.packages(c("http://mbni.org/customcdf/22.0.0/ensg.download/mouse4302mmensgcdf_22.0.0.tar.gz"));
# Install Mouse array: Affymetrix HT MG-430 PM Array Plate
install.packages(c("http://mbni.org/customcdf/22.0.0/ensg.download/htmg430pmmmensgcdf_22.0.0.tar.gz"));

# Install Rat array: Affymetrix Rat Genome 230 2.0 Array
install.packages(c("http://mbni.org/customcdf/22.0.0/ensg.download/rat2302rnensgcdf_22.0.0.tar.gz"));

