# Source for OpenCV Dependencies: https://github.com/JulianAssmann/opencv-cuda-docker/blob/master/ubuntu-20.04/opencv-4.5/cuda-11.1/Dockerfile

# Base image is from Ubuntu 18.04 that has CUDA 11.1 installed
# This is because Azure Kinect SDK only has official releases for Ubuntu 18.04
FROM nvidia/cuda:11.1-devel-ubuntu18.04

# Arguments for OpenCV
ARG OPENCV_VERSION=4.5.0

# Set timezone to Tokyo (for Naoki)
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# ----------------------------Linux Dependencies-------------------------
RUN apt-get update && apt-get upgrade -y &&\
    # Install Overall Dependencies
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
        # ESPNet only works for Python 3.7 and above -- installing 3.8 because Python 3.7 failed for the "pip install -e ." command
        python3-dev \ 
        python3-pip \
        python3.8-dev \
    # Install dependencies for ESPNet
    && apt-get -y install --no-install-recommends \ 
        apt-utils \
        gawk \
        libboost-all-dev \
        libbz2-dev \
        liblzma-dev \
        unzip \
        wget \
        zip \
    && apt-get clean \
    # Install Dependencies for Azure Kinect SDK
    && apt-get install -y \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/*
# -----------------------------------------------------------------------

# ----------------------------Python Dependencies------------------------
# Set Python 3.8 as default Python and Update pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 && \
    update-alternatives --set python3 /usr/bin/python3.8 && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade setuptools

RUN python3 -m pip install --no-cache-dir \
    numpy \
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
    jupyter
# -----------------------------------------------------------------------

# -----------------------------------HTK---------------------------------
COPY ./htk ./htk
COPY ./gt2k ./gt2k
COPY ./prepare ./htk/prepare
# Deleted LetterLevel and WordLevel folders because they are not used in this project

WORKDIR /htk
RUN chmod +x prepare
# This prepare script is where htk is built from scratch
RUN ./prepare 
# -----------------------------------------------------------------------

# -------------------------------ESPNET----------------------------------
WORKDIR /
# Install Kaldi inside of Espnet (source: http://jrmeyer.github.io/asr/2016/01/26/Installing-Kaldi.html)
RUN git clone https://github.com/espnet/espnet && \
    cd espnet/tools && \
    git clone https://github.com/kaldi-asr/kaldi.git && \
    # Ran the check_dependencies.sh script to check dependencies and saw that this needed to be run
    ./kaldi/tools/extras/install_mkl.sh && \
    cd kaldi/tools && \
    # Could not use -j due to packages not compiling. Removing -j fixed the issue: https://github.com/kaldi-asr/kaldi/issues/3987
    make && \
    ./extras/install_irstlm.sh && \
    cd ../src && \
    # Run configure script with the fix from this source: https://github.com/kaldi-asr/kaldi/issues/4391
    ./configure --shared --use-cuda && \
    make -j clean depend && \
    make -j"$(($((`free -g | grep '^Mem:' | grep -o '[^ ]\+$'`/2)) < $(nproc) ? $((`free -g | grep '^Mem:' | grep -o '[^ ]\+$'`/2)) : $(nproc)))"

# Install Espnet (source: https://espnet.github.io/espnet/installation.html)
# Additional resource: https://github.com/espnet/interspeech2019-tutorial/blob/master/notebooks/meetup/an4_meetup.ipynb
WORKDIR /espnet
RUN cd tools && \
    # Setup system Python environment
    ./setup_python.sh $(command -v python3)
RUN cd tools && make -j"$(($((`free -g | grep '^Mem:' | grep -o '[^ ]\+$'`/2)) < $(nproc) ? $((`free -g | grep '^Mem:' | grep -o '[^ ]\+$'`/2)) : $(nproc)))"
RUN cd tools && \
    ./activate_python.sh && \
    ./setup_cuda_env.sh /usr/local/cuda && \
    # Install optional dependencies for ESPNet
    ./installers/install_warp-ctc.sh && \
    ./installers/install_warp-transducer.sh && \
    ./installers/install_pyopenjtalk.sh && \
    python3 check_install.py
# -----------------------------------------------------------------------

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
    make -j"$(($((`free -g | grep '^Mem:' | grep -o '[^ ]\+$'`/2)) < $(nproc) ? $((`free -g | grep '^Mem:' | grep -o '[^ ]\+$'`/2)) : $(nproc)))" && \
    # Install to /usr/local/lib
    make install && \
    ldconfig && \
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
        libk4a1.4-dev && \
    python3 -m pip install pyk4a 
# ----------------------------------------------------------------------

# Future steps:
# - wget CopyCat Dataset from Dropbox
# - git clone CopyCat-HTK repo
# - Fix ESPNet issues
# Why is there no cuDNN? ( Could NOT find CUDNN (missing: CUDNN_LIBRARY CUDNN_INCLUDE_DIR) (Required is at least version "7.5"))