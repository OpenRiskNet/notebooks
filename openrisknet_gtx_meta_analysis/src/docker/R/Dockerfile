# Customized R version needed for meta-analysis
FROM r-base:3.4.0

LABEL maintainer="Jumamurat Bayjanov"

COPY ./install_bioconductor_and_packages.R /opt/

RUN R --file=/opt/install_bioconductor_and_packages.R

CMD ["R"]
