# choose ROS distribudion based on build argument
FROM ros:galactic-ros-base

SHELL ["/bin/bash", "-c"]

# install dependencies
RUN apt update && apt install -y \
    python3-pip \
    python3-colcon-common-extensions \
    ros-$ROS_DISTRO-robot-localization \
    ros-$ROS_DISTRO-teleop-twist-keyboard \
    ros-$ROS_DISTRO-rmw-fastrtps-cpp \
    ros-$ROS_DISTRO-rmw-cyclonedds-cpp


RUN apt upgrade -y 

WORKDIR /app

# create ros2_ws, copy and build package
RUN mkdir -p ros2_ws/src
COPY ./rosbot_xl_ekf /app/ros2_ws/src/rosbot_xl_ekf
RUN git clone https://github.com/micro-ROS/micro_ros_msgs.git --single-branch --branch=$ROS_DISTRO /app/ros2_ws/src/micro_ros_msgs \
    && git clone https://github.com/micro-ROS/micro-ROS-Agent.git --single-branch --branch=$ROS_DISTRO /app/ros2_ws/src/micro_ros_agent

RUN cd ros2_ws \
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && rosdep update --rosdistro $ROS_DISTRO \
    && colcon build --symlink-install
    
# clear ubuntu packages
RUN apt clean && \
    rm -rf /var/lib/apt/lists/*

ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

COPY ./ros_entrypoint.sh /
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

