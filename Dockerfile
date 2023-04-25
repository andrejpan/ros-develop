FROM ubuntu:20.04

# Remove geographic interactive questions
ARG DEBIAN_FRONTEND=noninteractive

# Update packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    curl \
    gnupg2 \
    lsb-release

# Set up sources for ROS 2
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

# Install ROS 2 Foxy
RUN apt-get update && apt-get install --no-install-recommends -y \
      ros-foxy-ros-base \
      python3-argcomplete \
      ros-dev-tools\
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create a non-root user that matches the host user
ARG USER_ID=1001
ARG GROUP_ID=1001
RUN addgroup --gid $GROUP_ID ros && \
    adduser --gecos "ROS User" --uid $USER_ID --gid $GROUP_ID --disabled-password ros && \
    echo "ros ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ros && \
    chmod 0440 /etc/sudoers.d/ros

# Set environment variables
ENV HOME=/home/ros
ENV USERNAME=ros
ENV USERID=$USER_ID
ENV GROUPID=$GROUP_ID

# Switch to the new user
USER ros

# Set up the ROS 2 environment
RUN echo "source /opt/ros/foxy/setup.bash" >> ~/.bashrc

CMD ["bash"]

###################################################################################################

# Build image
# docker build -t ubuntu2004-ros-foxy .

# Run image
# docker run -it --rm ubuntu2004-ros-foxy
# docker run -it --rm --user $(id -u):$(id -g) ubuntu2004-ros-foxy