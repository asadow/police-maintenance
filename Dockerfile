## Using older version of R due to rhandsontable date bug
## renv.lock was changed to reflect 4.2.2
FROM rocker/shiny-verse:4.2.2

LABEL maintainer="Adam Sadowski <asadowsk@uoguelph.ca>"

# For igraph from dm (GH issue: may become Suggested)
RUN apt-get -y update \
    && apt-get -y install \
    libglpk-dev \
    libgmp3-dev \
    libxml2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/

# renv install
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

RUN mkdir /home/app
WORKDIR /home/app

# Copy application code
COPY . .

# Install dependencies
RUN Rscript -e 'renv::restore(prompt = FALSE)'

EXPOSE 3838

CMD Rscript /home/app/app.R
