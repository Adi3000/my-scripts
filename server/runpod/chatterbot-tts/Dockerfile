FROM nvidia/cuda:12.9.2-cudnn-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive




# System packages
RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    ca-certificates \
    git \
    curl \
    ffmpeg \
    build-essential \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
ENV CONDA_DIR=/opt/conda
RUN wget -qO /tmp/miniconda.sh \
        https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh

ENV PATH=${CONDA_DIR}/bin:$PATH

# Update conda and create the Python 3.14 environment
RUN mkdir /workspace &&\
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main &&\
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r &&\
    conda update -n base -y conda && \
    conda create -y -n py314 python=3.14 pip && \
    conda clean -afy

# Automatically activate the environment for login shells
RUN echo "source ${CONDA_DIR}/etc/profile.d/conda.sh" >> /etc/bash.bashrc && \
    echo "conda activate py314" >> /etc/bash.bashrc

WORKDIR /workspace

ENV CONDA_DEFAULT_ENV=py314
RUN pip3 install "torch==2.11.0" "torchaudio==2.11.0" --index-url https://download.pytorch.org/whl/cu129 &&\
    pip3 install chatterbox-tts peft

CMD ["/bin/bash"]
