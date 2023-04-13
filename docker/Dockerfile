FROM ros:melodic

RUN apt-get update \
    && apt-get install -y ros-melodic-diagnostic-updater ros-melodic-controller-manager \
        ros-melodic-roslint ros-melodic-filters ros-melodic-joint-limits-interface wget \
        libmuparser-dev vim sudo ffmpeg libsm6 libxext6 python-pip lsb-release curl \
        ros-melodic-cv-bridge ros-melodic-ros-numpy gdb libgsl-dev tmux\
    && rm -rf /var/lib/apt/lists/*

# Install conda
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh

# Nopasswd sudo
ARG USER_ID
ARG GROUP_ID

RUN addgroup --gid $GROUP_ID user
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user

RUN chown user:user -R /root
RUN echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER user

ENV PATH="/home/user/.local/bin:${PATH}"
ENV PATH="/root/miniconda3/bin:${PATH}"
ENV PATH="/opt/ros/melodic/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/ros/melodic/lib:${LD_LIBRARY_PATH}"

#RUN rm -rf ~/.cache/pip
#RUN python2.7 -m pip install numpy tqdm

USER root
#RUN mkdir /catkin_ws
#RUN chown -R user:user /catkin_ws
#WORKDIR /catkin_ws

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
USER user

#RUN source /opt/ros/melodic/setup.bash && catkin_make
#RUN echo "source /catkin_ws/devel/setup.bash" >> ~/.bashrc

WORKDIR ~
COPY environment.yml environment.yml

RUN conda env create
#RUN conda env create -vv python=3.8.12
RUN conda init bash
RUN echo "conda activate can_bridge" >> ~/.bashrc

#RUN cd ../catkin_ws && source /opt/ros/melodic/setup.bash && catkin_make

#    echo "source /catkin_ws/devel/setup.bash" >> mypython && \
#    echo "source catkin_ws/devel/setup.bash" >> mypython && \

WORKDIR /root
RUN pwd

RUN echo '#!/bin/bash' >> mypython && \
    echo "source /opt/ros/melodic/setup.bash" >> mypython && \
    echo 'eval "$(/root/miniconda3/bin/conda shell.bash hook)"' >> mypython && \
    echo "conda activate can_bridge" >> mypython && \
    echo 'python "$@"' >> mypython
RUN chmod +x mypython

USER user

RUN /root/miniconda3/envs/can_bridge/bin/pip install pydevd-pycharm~=221.6008.17

#RUN /root/miniconda3/envs/inference_node/bin/pip install Cython
#RUN /root/miniconda3/envs/inference_node/bin/pip install onnx onnxruntime-gpu==1.6
