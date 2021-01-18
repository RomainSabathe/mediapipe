# Copyright 2019 The MediaPipe Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:18.04

MAINTAINER <mediapipe@google.com>

WORKDIR /io
WORKDIR /mediapipe

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        ffmpeg \
        git \
        wget \
        cmake \
        unzip \
        python3-dev \
        python3-opencv \
        python3-venv \
        python3-pip \
        protobuf-compiler \
        libprotobuf-dev \
        libgtk2.0-dev \
        libopencv-core-dev \
        libopencv-highgui-dev \
        libopencv-imgproc-dev \
        libopencv-video-dev \
        libopencv-calib3d-dev \
        libopencv-features2d-dev \
        software-properties-common \
        gcc-8 \
        gcc++-8 \
        # Necessary things to build opencv
        make  build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
        libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev \
        libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && apt-get install -y openjdk-8-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Installing python 3.8
ENV PATH="/mediapipe/.pyenv/bin:/mediapipe/.pyenv/shims:${PATH}"
ENV PYENV_ROOT="/mediapipe/.pyenv"
RUN git clone --recursive \
        https://github.com/pyenv/pyenv.git /mediapipe/.pyenv && \
    cd /mediapipe/.pyenv && \
    git checkout tags/v1.2.21

# Installing python.
RUN cd /mediapipe && \
    eval "$(pyenv init -)" && \
    pyenv install 3.8.6
RUN pyenv global 3.8.6
RUN pip3 install --upgrade setuptools
RUN pip3 install wheel future six==1.14.0 tf_slim scikit-build cmake
#RUN pip3  install tensorflow==1.14.0

# RUN ln -s /usr/bin/python3.8 /usr/bin/python

# Install bazel
ARG BAZEL_VERSION=3.4.1
RUN mkdir /bazel && \
    wget --no-check-certificate -O /bazel/installer.sh "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/b\
azel-${BAZEL_VERSION}-installer-linux-x86_64.sh" && \
    wget --no-check-certificate -O  /bazel/LICENSE.txt "https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE" && \
    chmod +x /bazel/installer.sh && \
    /bazel/installer.sh  && \
    rm -f /bazel/installer.sh

COPY requirements.txt /mediapipe/requirements.txt
RUN pip3 install -r requirements.txt 
COPY . /mediapipe/

# If we want the docker image to contain the pre-built object_detection_offline_demo binary, do the following
# RUN bazel build -c opt --define MEDIAPIPE_DISABLE_GPU=1 mediapipe/examples/desktop/demo:object_detection_tensorflow_demo
RUN python setup.py gen_protos
RUN python setup.py bdist_wheel
