FROM nvidia/cuda:9.0-cudnn7-devel

# Envrinment settings
ENV SETUSER root
ENV SRC_ROOT /home/$SETUSER/DeepSDF
ENV CONDA_ENV deepsdf
SHELL ["/bin/bash", "-c"]

# Apt
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y apt-utils software-properties-common
RUN apt-get install -y git wget curl zsh bzip2 unzip vim build-essential libssl-dev
RUN apt-get install -y mesa-utils mesa-common-dev libglu1-mesa-dev libglew-dev libglib2.0-dev

# Newer compiler
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN apt-get install -y gcc-9 g++-9
ENV CC gcc-9
ENV CXX g++-9

# Newer cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.5/cmake-3.16.5.tar.gz
RUN tar -zxf cmake-3.16.5.tar.gz
RUN cd cmake-3.16.5 && \
    ./bootstrap && \
    make -j && \
    make install 

# Oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -q -O miniconda.sh
RUN chmod +x miniconda.sh && ./miniconda.sh -b -p /opt/conda
ENV PATH /opt/conda/bin:$PATH
SHELL ["/usr/bin/zsh", "-c"]
RUN conda init zsh
RUN conda install python=3.7

# Eigen3
RUN git clone https://github.com/eigenteam/eigen-git-mirror eigen3
RUN cd eigen3 && git checkout 3.3.7 && \
    mkdir build && cd build && \
    cmake .. && make -j && make install

# CLI11
RUN git clone https://github.com/CLIUtils/CLI11
RUN cd CLI11 && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j && make install

# Pangolin
RUN git clone https://github.com/stevenlovegrove/Pangolin
RUN cd Pangolin && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j && make install

# nanoflann
RUN git clone https://github.com/jlblancoc/nanoflann
RUN cd nanoflann && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j && make install
RUN mkdir /usr/local/include/nanoflann && \
    cp nanoflann/include/nanoflann.hpp /usr/local/include/nanoflann

# Clone repo
RUN git clone --recurse-submodules https://github.com/tatsy/DeepSDF $SRC_ROOT

# Setup
RUN cd $SRC_ROOT && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=17 .. && \
    make -j && make install

RUN conda env create --file environment.yaml
RUN echo "conda activate $CONDA_ENV" >> ~/.zshrc

WORKDIR $SRC_ROOT
CMD ["/usr/bin/zsh"]
