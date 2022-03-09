# Source for OpenCV Dependencies: https://github.com/JulianAssmann/opencv-cuda-docker/blob/master/ubuntu-20.04/opencv-4.5/cuda-11.1/Dockerfile
# Source for ESPNet: Naoki's DockerFile

# Base image is from Ubuntu 18.04 that has CUDA 11.1 installed
# This is because Azure Kinect SDK only has official releases for Ubuntu 18.04
FROM nvidia/cuda:11.1-devel-ubuntu18.04

# Arguments for OpenCV
ARG OPENCV_VERSION=4.5.0

# Set timezone to Tokyo (for Naoki)
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Linux Dependencies
RUN apt-get update && apt-get upgrade -y &&\
    # Install Dependencies for ESPNet
    apt-get install -y --no-install-recommends \
        g++ \
        make \
        cmake \
        automake \
        autoconf \
        bzip2 \
        unzip \
        wget \
        sox \
        libtool \
        git \
        subversion \
        zlib1g-dev \
        gfortran \
        ca-certificates \
        patch \
        ffmpeg \
        libsndfile1-dev \
        flac \
        vim \
        curl \
        nkf \
        libfreetype6-dev \
    # Install Dependencies for HTK
    && apt-get install -y libc6-dev-i386 \
        ksh \
        bc \
        libx11-dev \
    # Install Dependencies for OpenCV
    && apt-get install -y \
    python3-pip \
        build-essential \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libavformat-dev \
        libpq-dev \
        libxine2-dev \
        libglew-dev \
        libtiff5-dev \
        zlib1g-dev \
        libjpeg-dev \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libpostproc-dev \
        libswscale-dev \
        libeigen3-dev \
        libtbb-dev \
        libgtk2.0-dev \
        pkg-config \
        python3-dev \
        python3-numpy \
    # Install Dependencies for Azure Kinect SDK
    && apt-get install -y \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------HTK-----------------------------------
COPY ./htk ./htk
COPY ./gt2k ./gt2k
COPY ./LetterLevel ./LetterLevel
COPY ./prepare ./htk/prepare
COPY ./WordLevel ./WordLevel

WORKDIR /htk
RUN chmod +x prepare
# This prepare script is where htk is built from scratch
RUN ./prepare 
# -------------------------------------------------------------------------

# # -------------------------------ESPNET----------------------------------
# #RUN ln -s /usr/bin/python3 /usr/bin/python

# #RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
# #RUN python get-pip.py

# #RUN pip3 install torch numpy kaldiio humanfriendly soundfile typeguard espnet jupyter
# #WORKDIR /
# RUN git clone https://github.com/espnet/espnet.git
# #RUN git clone https://github.com/kaldi-asr/kaldi.git

# WORKDIR /espnet/tools
# #RUN ln -s $(pwd)/../../kaldi .
# RUN ./setup_anaconda.sh anaconda espnet 3.8
# RUN make
# #RUN ./setup_python.sh $(command -v python3
# # # -----------------------------------------------------------------------

# -------------------------------OpenCV----------------------------------
WORKDIR /
RUN cd /opt/ &&\
    # Download and unzip OpenCV and opencv_contrib and delete zip files
    wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip &&\
    unzip $OPENCV_VERSION.zip &&\
    rm $OPENCV_VERSION.zip &&\
    wget https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip &&\
    unzip ${OPENCV_VERSION}.zip &&\
    rm ${OPENCV_VERSION}.zip &&\
    # Create build folder and switch to it
    mkdir /opt/opencv-${OPENCV_VERSION}/build && cd /opt/opencv-${OPENCV_VERSION}/build &&\
    # Cmake configure
    cmake \
        -DOPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-${OPENCV_VERSION}/modules \
        -DWITH_CUDA=ON \
        -DCMAKE_BUILD_TYPE=RELEASE \
        # Install path will be /usr/local/lib (lib is implicit)
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        .. &&\
    # Make
    make -j"$(nproc)" && \
    # Install to /usr/local/lib
    make install && \
    ldconfig &&\
    # Remove OpenCV sources and build folder
    rm -rf /opt/opencv-${OPENCV_VERSION} && rm -rf /opt/opencv_contrib-${OPENCV_VERSION}
# -----------------------------------------------------------------------

# ----------------------------Azure Kinect SDK---------------------------
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-add-repository https://packages.microsoft.com/ubuntu/18.04/prod && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install k4a-tools -y && \
    apt-get install -y \
        libk4a1.4 \
        libk4a1.4-dev
# ----------------------------------------------------------------------

# ----------------------------Python Dependencies-----------------------
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir\
    torch \
    matplotlib \
    plotly \
    scipy \
    scikit-learn \
    pandas \
    tqdm \
    pytransform3d \
    joblib \
    mediapipe \
    pyk4a \
    filterpy \
    pympi-ling \
    ffprobe-python \
    tf-bodypix \
    tfjs-graph-converter \
    tensorflow \
    typing-extensions \
    kaldiio \
    humanfriendly \
    soundfile \
    typeguard \
    espnet \
    jupyter
# ----------------------------------------------------------------------

# Future steps:
# - wget CopyCat Dataset from Dropbox
# - git clone CopyCat-HTK repo
# - Fix ESPNet issues
# Why is there no cuDNN? ( Could NOT find CUDNN (missing: CUDNN_LIBRARY CUDNN_INCLUDE_DIR) (Required is at least version "7.5"))