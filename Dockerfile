## Using older version of R due to rhandsontable date bug
## renv.lock was changed to reflect 4.1.3
FROM openanalytics/r-ver:4.1.3

LABEL maintainer="Adam Sadowski <asadowsk@uoguelph.ca>"

# system libraries of general use
RUN apt-get update && apt-get install --no-install-recommends -y \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.1 \
    && rm -rf /var/lib/apt/lists/*

# system library dependency
RUN apt-get update && apt-get install -y \
    libmpfr-dev \
    && rm -rf /var/lib/apt/lists/*

# install dependencies of the app
COPY renv.lock .
RUN R -q -e "renv::init();renv::restore()"

# copy the app to the image
RUN mkdir /root/police-maintenance
COPY . /root/police-maintenance

COPY Rprofile.site /usr/local/lib/R/etc/

EXPOSE 3838

## Can change to rhino::app() but need to change WORKDIR first as
## rhino::app() does not take a path?
CMD ["R", "-q", "-e", "shiny::runApp('/root/police-maintenance')"]
