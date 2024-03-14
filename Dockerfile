## Using older version of R due to rhandsontable date bug
## renv.lock was changed to reflect 4.2.2
FROM rocker/shiny-verse:4.2.2

LABEL maintainer="Adam Sadowski <asadowsk@uoguelph.ca>"

## For igraph from dm (GH issue: may become Suggested)
RUN apt-get -y update && apt-get -y install \
    libglpk-dev \
    libgmp3-dev \
    libxml2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/

## Install renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

## NB path is rocker-specific. Regular path is /usr/lib/R/etc/
## Can instead add host='0.0.0.0', port=3838 to shiny::runApp() at CMD
RUN echo "local(options(shiny.port = 3838, shiny.host = '0.0.0.0'))" > /usr/local/lib/R/etc/Rprofile.site

RUN mkdir /home/app
WORKDIR /home/app
## Copy application code
COPY shiny .
## Install dependencies
RUN Rscript -e 'renv::restore()'

## BREAKS RENV
## Set up non-root user
#RUN addgroup --system app \
#    && adduser --system --ingroup app app
#RUN chown app:app -R .
#USER app

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/home/app/')"]
