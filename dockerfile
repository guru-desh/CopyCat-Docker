# A good explanation of the job flag for makefiles: https://www.gnu.org/software/make/manual/html_node/Parallel.html

# Base image is from Ubuntu 18.04 that has CUDA 11.1 installed
# This is because Azure Kinect SDK only has official releases for Ubuntu 18.04
# Changed CUDA to 10.2 because of nvcc error when building chainer-ctc, warp-transducer for ESPnet. Fix was to downgrade from CUDA 11 to CUDA 10.2: https://github.com/espnet/espnet/issues/2177
FROM nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04

# Arguments for OpenCV
ARG OPENCV_VERSION=4.3.0

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
    && apt-get update && apt-get upgrade -y && apt-get install -y libc6-dev-i386 \
        ksh \
        bc \
        libx11-dev \
    # Install Dependencies for OpenCV
    && apt-get update && apt-get upgrade -y && apt-get install -y \
    python3-pip \
        build-essential \
        yasm \
        pkg-config \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libpq-dev \
        libxine2-dev \
        libglew-dev \
        libtiff5-dev \
        zlib1g-dev \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libpostproc-dev \
        libswscale-dev \
        libeigen3-dev \
        libgtk2.0-dev \
        # ESPnet only works for Python 3.7 and above -- installing 3.8 because Python 3.7 failed for the "pip install -e ." command
        python3-dev \ 
        python3-pip \
        python3.8-dev \
    # Install dependencies for ESPnet
    && apt-get update && apt-get upgrade -y && apt-get -y install --no-install-recommends \ 
        apt-utils \
        gawk \
        libboost-all-dev \
        libbz2-dev \
        liblzma-dev \
        unzip \
        wget \
        zip \
        # Needed for installation of phonemizer (used by ESPnet)
        libncurses5-dev \
        libncursesw5-dev \
    # Install Dependencies for Azure Kinect SDK
    && apt-get update && apt-get upgrade -y && apt-get install -y \
        software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# -----------------------------------------------------------------------

# -------------------------------Python Setup----------------------------
# Set Python 3.8 as default Python and Update pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2 && \
    update-alternatives --set python3 /usr/bin/python3.8 && \
    update-alternatives --set python /usr/bin/python3.8 && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade setuptools
# -----------------------------------------------------------------------

# ---------------------------------HTK-----------------------------------
COPY ./htk ./htk
COPY ./gt2k ./gt2k
COPY ./prepare ./htk/prepare
# Deleted LetterLevel and WordLevel folders because they are not used in this project

WORKDIR /htk
RUN chmod +x prepare
# This prepare script is where htk is built from scratch
RUN ./prepare 
# -----------------------------------------------------------------------

# -------------------------------ESPnet----------------------------------
WORKDIR /
# Install Kaldi inside of ESPnet (source: http://jrmeyer.github.io/asr/2016/01/26/Installing-Kaldi.html)
RUN git clone https://github.com/espnet/espnet
    # cd espnet/tools && \
    # git clone https://github.com/kaldi-asr/kaldi.git && \
    # # Ran the check_dependencies.sh script to check dependencies and saw that this needed to be run
    # ./kaldi/tools/extras/install_mkl.sh && \
    # cd kaldi/tools && \
    # # Could not use -j due to packages not compiling. Removing -j fixed the issue: https://github.com/kaldi-asr/kaldi/issues/3987
    # make && \
    # ./extras/install_irstlm.sh && \
    # cd ../src && \
    # # Run configure script with the fix from this source: https://github.com/kaldi-asr/kaldi/issues/4391
    # ./configure --shared --use-cuda && \
    # make -j clean depend && \
    # make -j"$(($(($((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) < $(nproc) ? $((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) : $(nproc)))>1 ? $(($((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) < $(nproc) ? $((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) : $(nproc))) : 1))"

# Install ESPnet (source: https://espnet.github.io/espnet/installation.html)
# Additional resource: https://github.com/espnet/interspeech2019-tutorial/blob/master/notebooks/meetup/an4_meetup.ipynb
# WORKDIR /espnet
# RUN cd tools && \
#     # Without setting Python environment.
#     rm -f activate_python.sh && touch activate_python.sh && \
#     # Must pip install this to avoid errors
#     python3 -m pip install chainer==6.0.0
# RUN cd tools && make -j"$(($(($((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) < $(nproc) ? $((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) : $(nproc)))>1 ? $(($((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) < $(nproc) ? $((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) : $(nproc))) : 1))"
# RUN cd tools && \
#     bash ./activate_python.sh && \
#     ./setup_cuda_env.sh /usr/local/cuda && \
#     # Based on running the python3 check_install.py, these packages need to be installed
#     ./installers/install_chainer_ctc.sh && \
#     ./installers/install_kenlm.sh && \
#     ./installers/install_py3mmseg.sh && \
#     ./installers/install_phonemizer.sh && \
#     ./installers/install_gtn.sh && \
#     ./installers/install_s3prl.sh && \
#     ./installers/install_transformers.sh && \
#     ./installers/install_speechbrain.sh && \
#     ./installers/install_k2.sh && \
#     ./installers/install_longformer.sh && \
#     ./installers/install_pesq.sh && \
#     ./installers/install_beamformit.sh && \
#     # Optional packages for ESPnet
#     ./installers/install_warp-ctc.sh && \
#     ./installers/install_warp-transducer.sh && \
#     ./installers/install_pyopenjtalk.sh && \
#     python3 check_install.py
# -----------------------------------------------------------------------

# -------------------------------OpenCV----------------------------------
# Source: https://github.com/JulianAssmann/opencv-cuda-docker/blob/master/ubuntu-20.04/opencv-4.5/cuda-11.1/Dockerfile
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
    make -j"$(($(($((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) < $(nproc) ? $((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) : $(nproc)))>1 ? $(($((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) < $(nproc) ? $((`free -g | grep '^Mem:' | grep -o '[^ ]*$'`/2)) : $(nproc))) : 1))" && \
    # Install to /usr/local/lib
    make install && \
    ldconfig && \
    # Remove OpenCV sources and build folder
    rm -rf /opt/opencv-${OPENCV_VERSION} && rm -rf /opt/opencv_contrib-${OPENCV_VERSION}
# -----------------------------------------------------------------------

# ----------------------------Azure Kinect SDK---------------------------
# In order to use apt-add-repository, we need to go back to Python3.6 as the default
RUN update-alternatives --set python3 /usr/bin/python3.6 && \
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-add-repository https://packages.microsoft.com/ubuntu/18.04/prod && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install k4a-tools -y && \
    apt-get install -y \
        libk4a1.4 \
        libk4a1.4-dev && \
    update-alternatives --set python3 /usr/bin/python3.8 && \
    python3 -m pip install pyk4a 
# -----------------------------------------------------------------------

# --------------------------Python Dependencies--------------------------
# Will install all dependencies for the project simply by looking at the imports for the CopyCat-HTK repo. 
# ESPnet already installs a majority of them
# However, pip will just say "requirement installed" if it is already installed
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
    # mediapipe \
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
    jupyter \
    p-tqdm
# -----------------------------------------------------------------------

# -------------------------------CopyCat---------------------------------
# Download the CopyCat-HTK repository
RUN git clone -b DataAugmentation https://github.com/ishanchadha01/CopyCat-HTK.git
# -----------------------------------------------------------------------
