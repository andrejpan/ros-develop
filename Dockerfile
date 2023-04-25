
FROM osrf/ros:iron-desktop-full
# Set the default shell of an image.
SHELL ["/bin/bash", "-c"]

# Install necessary tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash-completion \
    cmake-curses-gui \
    cron \
    htop \
    gdb \
    git \
    iproute2 \
    iputils-ping \
    libxcb-cursor0 \
    python3-pip \
    ros-iron-nav2-bringup \
    ros-iron-navigation2 \
    ros-iron-turtlebot3* \
    # killall
    psmisc \
    vim

# Jazzy image already includes ubuntu user
ARG USERNAME=ubuntu
# Check uid and gid on local machine!
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# Name of ROS environment in home directory
ARG ROS_ENV=ros2_ws

# create custom user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config

# Set up sudo
RUN apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME

USER ${USERNAME}
# Create a workspace
RUN mkdir -p /home/$USERNAME/${ROS_ENV}/src

# Install dependencies
WORKDIR /home/$USERNAME/${ROS_ENV}

# Set the entrypoint
COPY scripts/entrypoint.sh .
COPY scripts/bashrc /home/${USERNAME}/bashrc
RUN cat /home/${USERNAME}/bashrc >> /home/${USERNAME}/.bashrc \
  && rm /home/${USERNAME}/bashrc

USER root
RUN apt-get update \
  && rosdep install --from-paths src --ignore-src --rosdistro iron -r -y

# Run upgrade command if there are some outdated packages
RUN apt-get update \
  && apt-get -y upgrade

USER ${USERNAME}
ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]
CMD ["bash"]