# From https://gitlab.com/nvidia/container-images/cuda/blob/master/doc/supported-tags.md
FROM nvidia/cuda:12.6.1-cudnn-devel-ubuntu24.04

RUN yes | unminimize

# RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# RUN wget https://packages.cloud.google.com/apt/doc/apt-key.gpg && apt-key add apt-key.gpg
# RUN apt-get update && \
#   apt-get install -y --no-install-recommends wget curl tmux vim git gdebi-core \
#   build-essential python3-pip unzip google-cloud-sdk htop mesa-utils xorg-dev xorg \
#   libglvnd-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev xvfb && \
#   wget http://security.ubuntu.com/ubuntu/pool/main/libx/libxfont/libxfont1_1.5.1-1ubuntu0.16.04.4_amd64.deb && \
#   yes | gdebi libxfont1_1.5.1-1ubuntu0.16.04.4_amd64.deb

# 必要そうなパッケージをインストール
RUN apt-get update && apt-get install -y --no-install-recommends wget curl tmux vim git build-essential libreadline-dev \ 
  libncursesw5-dev libssl-dev libsqlite3-dev libgdbm-dev libbz2-dev liblzma-dev zlib1g-dev uuid-dev libffi-dev libdb-dev
# Python 3.10.12 をインストール
RUN wget --no-check-certificate https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz \
  && tar xvf Python-3.10.12.tgz \
  && cd Python-3.10.12 \
  && ./configure \
  && make -j 8 \
  && make install
# メモリ節約のため不要なファイルを削除
RUN apt-get autoremove -y
# python コマンドの参照先を Python 3.10.12 に変更
RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 1

RUN python -m pip install --upgrade pip
RUN pip install setuptools

ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

#checkout ml-agents for SHA
RUN mkdir /ml-agents
WORKDIR /ml-agents
ARG SHA
RUN git init
RUN git remote add origin https://github.com/Unity-Technologies/ml-agents.git
RUN git fetch --depth 1 origin $SHA
RUN git checkout FETCH_HEAD
RUN pip install mlagents_envs==1.1.0
RUN pip install mlagents==1.1.0
