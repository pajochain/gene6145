# Run samtools in a container
#
#
# docker run -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix:rw --privileged -e DISPLAY=unix$DISPLAY -v $HOME/:/home/training/ --device /dev/dri --privileged --name pymol ebitraining/pymol:alpha /bin/bash
# 
# docker run --rm -it -v $HOME/:/home/training/ --device /dev/dri --privileged --name samtools ebitraining/samtools:alpha /bin/bash
#
#
# Run on Nvidia graphics
#
# docker run -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix:rw --privileged -e DISPLAY=unix$DISPLAY -v $HOME/:/home/training/ -v /usr/lib/nvidia-340:/usr/lib/nvidia-340 -v /usr/lib32/nvidia-340:/usr/lib32/nvidia-340 --device /dev/dri --privileged --name samtools ebitraining/samtools:alpha /bin/bash
#
# USAGE:
#	# Build cytoscape image
#	docker build -f ./Dockerfile -t samtools .
#

FROM ubuntu:16.04

LABEL author="Mohamed Alibi" \
description="SAMTools: Reading/writing/editing/indexing/viewing SAM/BAM/CRAM format." \
maintainer="Paulo Tanicala"

# Download Samtools and libraries 
ADD https://github.com/samtools/samtools/releases/download/1.7/samtools-1.7.tar.bz2 /usr/local/samtools-1.7.tar.bz2
ADD https://github.com/samtools/bcftools/releases/download/1.7/bcftools-1.7.tar.bz2 /usr/local/bcftools-1.7.tar.bz2
ADD https://github.com/samtools/htslib/releases/download/1.7/htslib-1.7.tar.bz2 /usr/local/htslib-1.7.tar.bz2

# Install libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	ca-certificates \
	libbz2-dev \
	liblzma-dev \
	libncurses5-dev \
	libncursesw5-dev \
	libcurl4-openssl-dev \
	libcurl3 \
	zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/*

# Install htslib
RUN tar xvjf /usr/local/htslib-1.7.tar.bz2 -C /usr/local/ \
	&& cd /usr/local/htslib-1.7 \
	&& ./configure \
	&& make \
	&& make install \
	&& rm /usr/local/htslib-1.7.tar.bz2

# Install bcftools
RUN tar xvjf /usr/local/bcftools-1.7.tar.bz2 -C /usr/local/ \
	&& cd /usr/local/bcftools-1.7 \
	&& ./configure \
	&& make \
	&& make install \
	&& rm /usr/local/bcftools-1.7.tar.bz2

# Install samtools
RUN tar xvjf /usr/local/samtools-1.7.tar.bz2 -C /usr/local/ \
	&& cd /usr/local/samtools-1.7 \
	&& ./configure \
	&& make \
	&& make install \
	&& rm /usr/local/samtools-1.7.tar.bz2

# Setup the user envirenment
ENV HOME /home/training

RUN useradd --create-home --home-dir $HOME training \
	&& chown -R training:training $HOME \
	&& usermod -a -G audio,video training

WORKDIR $HOME
USER training
