FROM ubuntu:16.04

MAINTAINER Brendan Harmon <brendan.harmon@gmail.com>

# system environment
ENV DEBIAN_FRONTEND noninteractive

USER root

# compile jupyter
RUN apt-get update \
    && apt-get install -y \
      python-pip \
    && apt-get autoremove \
    && apt-get clean
RUN python -m pip install --upgrade pip
RUN python -m pip install numpy \
  scipy \
  matplotlib \
  ipython \
  jupyter \
  pandas \
  sympy \
  nose \
  ggplot

# GRASS GIS compile dependencies
RUN apt-get update \
    && apt-get install -y --install-recommends \
        autoconf2.13 \
        autotools-dev \
        bison \
        flex \
        g++ \
        gettext \
        libblas-dev \
        libbz2-dev \
        libcairo2 \
        libcairo2-dev \
        libfftw3-dev \
        libfreetype6-dev \
        libgdal-dev \
        libgeos-dev \
        libglu1-mesa-dev \
        libjpeg-dev \
        liblapack-dev \
        liblas-c-dev \
        libncurses5-dev \
        libnetcdf-dev \
        libpng-dev \
        libpq-dev \
        libproj-dev \
        libreadline-dev \
        libsqlite3-dev \
        libtiff-dev \
        libxmu-dev \
        libav-tools \
        libavutil-dev \
        ffmpeg2theora \
        libffmpegthumbnailer-dev \
        libavcodec-dev \
        libxmu-dev \
        libavformat-dev \
        libswscale-dev \
        make \
        netcdf-bin \
        proj-bin \
        python \
        python-dev \
        python-numpy \
        python-pil \
        python-ply \
        python-dateutil \
        libgsl-dev \
        python-matplotlib \
        python-watchdog \
        unixodbc-dev \
        zlib1g-dev \
        sqlite3 \
        libgomp1 \
    && apt-get autoremove \
    && apt-get clean

# other software
RUN apt-get update \
    && apt-get install -y --install-recommends \
        imagemagick \
        p7zip \
        subversion \
        git-core \
    && apt-get autoremove \
    && apt-get clean

# install GRASS GIS
# using a specific revision, otherwise we can't apply the path safely
WORKDIR /usr/local/src
RUN svn checkout -r 73003 https://svn.osgeo.org/grass/grass/trunk grass \
    && cd grass \
    &&  ./configure \
        --enable-largefile=yes \
        --with-nls \
        --with-cxx \
        --with-readline \
        --with-bzlib \
        --with-pthread \
        --with-proj-share=/usr/share/proj \
        --with-geos=/usr/bin/geos-config \
        --with-cairo \
        --with-opengl-libs=/usr/include/GL \
        --with-freetype=yes --with-freetype-includes="/usr/include/freetype2/" \
        --with-sqlite=yes \
        --with-openmp \
        --with-netcdf \
        --with-python-pillow \
        --with-ffmpeg \
        --with-mpeg-encode \
        --with-python-ply \
        --with-r \
        --with-numpy \
        --with-liblas=yes --with-liblas-config=/usr/bin/liblas-config \
    && make && make install && ldconfig

# enable simple grass command regardless of version number
RUN ln -s /usr/local/bin/grass* /usr/local/bin/grass

# install GRASS GIS extensions
RUN mkdir /code
WORKDIR /code
COPY Makefile .
COPY r.sim.terrain.py .
COPY r.sim.terrain.html .
RUN grass --tmp-location -c EPSG:4326 --exec g.extension r.sim.terrain url=/code
RUN grass --tmp-location -c EPSG:4326 --exec g.extension r.geomorphon
RUN grass --tmp-location -c EPSG:4326 --exec g.extension r.skyview
RUN grass --tmp-location -c EPSG:4326 --exec g.extension r.lake.series
RUN grass --tmp-location -c EPSG:4326 --exec g.extension r.stream
RUN grass --tmp-location -c EPSG:4326 --exec g.extension r.sun.daily
RUN grass --tmp-location -c EPSG:4326 --exec g.extension r.sun.hourly

# pull grassdata directory
RUN mkdir /grassdata
WORKDIR /grassdata
RUN git clone https://github.com/baharmon/landscape_evolution_dataset.git

# copy jupyter notebooks
RUN mkdir /data
WORKDIR /data
COPY notebooks/* ./

# create a user
RUN useradd -m -U jovyan

# change the owner so that the user can execute
RUN chown -R jovyan:jovyan /data

# switch the user
USER jovyan

CMD jupyter notebook --ip=0.0.0.0 --port=8080
