#!/bin/bash

set -e

# Source ROS 2 setup
source /opt/ros/iron/setup.bash

exec "$@"