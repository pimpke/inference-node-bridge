import os
import sys
import time
from datetime import datetime
from multiprocessing.connection import Listener

import rospy


def log_mono_timestamp_to_ros_timestamp(log_mono_time: int) -> int:
    return rospy.Time.now().to_nsec() - time.clock_gettime_ns(time.CLOCK_BOOTTIME) + log_mono_time


rospy.init_node('inference_node_bridge')

try:
    if os.environ['DEBUG_INFERENCE_NODE_BRIDGE'] == '1':
      import pydevd_pycharm

      pydevd_pycharm.settrace('localhost', port=1235, stdoutToServer=True, stderrToServer=True)
except KeyError:
    pass

with Listener(('localhost', 7777)) as listener:
    while True:
        with listener.accept() as conn:
            print('Connection accepted from', listener.last_accepted)

            try:
                while True:
                    data_dict = conn.recv()
                    data_dict['log_mono_timestamp'] = \
                        log_mono_timestamp_to_ros_timestamp(data_dict['log_mono_timestamp'])

                    readable_datetime = datetime.utcfromtimestamp(data_dict['log_mono_timestamp'] / 1e9) \
                        .strftime('%Y-%m-%d %H:%M:%S')
                    print(readable_datetime)
                    print(data_dict)
            except Exception as e:
                print(e)
