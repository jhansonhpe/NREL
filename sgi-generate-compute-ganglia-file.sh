#  Copyright (c) 2007,2008,2014-2018 Hewlett Packard Enterprise Development LP
#  All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# This script generates the /etc/gmond.conf file for the compute node.
#

##############################################################################


function sgi-generate-compute-ganglia-file() {

blade_path=$1 # e.g. /var/lib/sgi/per-host/<imagename>/i2n11

node=${NAME}

iru=${node##r*i}
iru=${iru%%n*}
slot=${node##r*i*n}
gbe_ip=${GBE_IP}

########################
# 1. WRITE GMOND  FILE
########################

cat <<EOF >$blade_path/etc/ganglia/gmond.conf
#
# This file has been automatically created by the Cluster Manager.
# Please do not modify its content.
#

/* This configuration is as close to 2.5.x default behavior as possible
   The values closely match ./gmond/metric.h definitions in 2.5.x */
globals {
  override_hostname = $node
  override_ip = $gbe_ip
  daemonize = yes
  setuid = yes
  user = nobody
  debug_level = 0
  max_udp_msg_len = 1472
  mute = no
  deaf = yes
  host_dmax = 0 /*secs */
  cleanup_threshold = 300 /*secs */
  gexec = no
  send_metadata_interval = 60
}

/* If a cluster attribute is specified, then all gmond hosts are wrapped inside
 * of a <CLUSTER> tag.  If you do not specify a cluster tag, then all <HOSTS> will
 * NOT be wrapped inside of a <CLUSTER> tag. */
cluster {
   name = "Rack $RACK"
   owner = "OSCAR"
   latlong = "unspecified"
   url = "unspecified"
}

/* The host section describes attributes of the host, like the location */
host {
  location = "$RACK, $iru, $slot"
}

/* Feel free to specify as many udp_send_channels as you like.  Gmond
   used to only support having a single channel */

udp_send_channel {
   host = lead-eth              # send admin metrics to itself via unicast
   port = 8649
}

udp_recv_channel {             #needed for ganglia core 3.6 
   port = 8649
}

/* You can specify as many tcp_accept_channels as you like to share
   an xml description of the state of the cluster */
tcp_accept_channel {
  port = 8649
  family = inet4
}
tcp_accept_channel {
  port = 8649
  family = inet6
}

/* Each metrics module that is referenced by gmond must be specified and
   loaded. If the module has been statically linked with gmond, it does not
   require a load path. However all dynamically loadable modules must include
   a load path. */
modules {
  module {
    name = "core_metrics"
  }
  module {
    name = "cpu_module"
    path = "/usr/lib64/ganglia/modcpu.so"
  }
  module {
    name = "disk_module"
    path = "/usr/lib64/ganglia/moddisk.so"
  }
  module {
    name = "load_module"
    path = "/usr/lib64/ganglia/modload.so"
  }
  module {
    name = "mem_module"
    path = "/usr/lib64/ganglia/modmem.so"
  }
  module {
    name = "net_module"
    path = "/usr/lib64/ganglia/modnet.so"
  }
  module {
    name = "proc_module"
    path = "/usr/lib64/ganglia/modproc.so"
  }
  module {
    name = "sys_module"
    path = "/usr/lib64/ganglia/modsys.so"
  }
}

include ('/etc/ganglia/conf.d/*.conf')


/* The old internal 2.5.x metric array has been replaced by the following
   collection_group directives.  What follows is the default behavior for
   collecting and sending metrics that is as close to 2.5.x behavior as
   possible. */

/* This collection group will cause a heartbeat (or beacon) to be sent every
   20 seconds.  In the heartbeat is the GMOND_STARTED data which expresses
   the age of the running gmond. */
collection_group {
  collect_once = yes
  time_threshold = 20
  metric {
    name = "heartbeat"
  }
}

/* This collection group will send general info about this host every 1200 secs.
   This information doesn't change between reboots and is only collected once. */
collection_group {
  collect_once = yes
  time_threshold = 1200
  metric {
    name = "cpu_num"
    title = "CPU Count"
  }
  metric {
    name = "cpu_speed"
    title = "CPU Speed"
  }
  metric {
    name = "mem_total"
    title = "Memory Total"
  }
  metric {
    name = "boottime"
    title = "Last Boot Time"
  }
  metric {
    name = "machine_type"
    title = "Machine Type"
  }
  metric {
    name = "os_name"
    title = "Operating System"
  }
  metric {
    name = "os_release"
    title = "Operating System Release"
  }
  metric {
    name = "location"
    title = "Location"
  }
}

/* This collection group will collect the CPU status info every 20 secs.
   The time threshold is set to 90 seconds.  In honesty, this time_threshold could be
   set significantly higher to reduce unneccessary network chatter. */
collection_group {
  collect_every = 20
  time_threshold = 90
  /* CPU status */
  metric {
    name = "cpu_user"
    value_threshold = "1.0"
    title = "CPU User"
  }
  metric {
    name = "cpu_system"
    value_threshold = "1.0"
    title = "CPU System"
  }
  metric {
    name = "cpu_idle"
    value_threshold = "5.0"
    title = "CPU Idle"
  }
  metric {
    name = "cpu_nice"
    value_threshold = "1.0"
    title = "CPU Nice"
  }
  metric {
    name = "cpu_aidle"
    value_threshold = "5.0"
    title = "CPU aidle"
  }
  metric {
    name = "cpu_wio"
    value_threshold = "1.0"
    title = "CPU wio"
  }
}

collection_group {
  collect_every = 20
  time_threshold = 90
  /* Load Averages */
  metric {
    name = "load_one"
    value_threshold = "1.0"
    title = "One Minute Load Average"
  }
  metric {
    name = "load_five"
    value_threshold = "1.0"
    title = "Five Minute Load Average"
  }
  metric {
    name = "load_fifteen"
    value_threshold = "1.0"
    title = "Fifteen Minute Load Average"
  }
}

/* This group collects the number of running and total processes */
collection_group {
  collect_every = 80
  time_threshold = 950
  metric {
    name = "proc_run"
    value_threshold = "1.0"
    title = "Total Running Processes"
  }
}

/* This collection group grabs the volatile memory metrics every 40 secs and
   sends them at least every 180 secs.  This time_threshold can be increased
   significantly to reduce unneeded network traffic. */
collection_group {
  collect_every = 40
  time_threshold = 180
  metric {
    name = "mem_free"
    value_threshold = "1024.0"
    title = "Free Memory"
  }
  metric {
    name = "mem_shared"
    value_threshold = "1024.0"
    title = "Shared Memory"
  }
  metric {
    name = "mem_buffers"
    value_threshold = "1024.0"
    title = "Memory Buffers"
  }
  metric {
    name = "mem_cached"
    value_threshold = "1024.0"
    title = "Cached Memory"
  }
}

collection_group {
  collect_every = 40
  time_threshold = 300
  metric {
    name = "bytes_out"
    value_threshold = 4096
    title = "Bytes Sent"
  }
  metric {
    name = "bytes_in"
    value_threshold = 4096
    title = "Bytes Received"
  }
  metric {
    name = "pkts_in"
    value_threshold = 256
    title = "Packets Received"
  }
  metric {
    name = "pkts_out"
    value_threshold = 256
    title = "Packets Sent"
  }
}

/* Different than 2.5.x default since the old config made no sense */
collection_group {
  collect_every = 1800
  time_threshold = 3600
  metric {
    name = "disk_total"
    value_threshold = 1.0
    title = "Total Disk Space"
  }
}

collection_group {
  collect_every = 40
  time_threshold = 180
  metric {
    name = "disk_free"
    value_threshold = 1.0
    title = "Disk Space Available"
  }
  metric {
    name = "part_max_used"
    value_threshold = 1.0
    title = "Maximum Disk Space Used"
  }
}

modules {
  module {
    name = 'procstat'
    language = 'python'

    # gmond with default configuration file
    param gmond {
      value = '/gmond$/'
    }
  }
}

collection_group {
  collect_every = 30
  time_threshold = 30

  metric {
    name_match = "procstat_(.+)_cpu"
  }

  metric {
    name_match = "procstat_(.+)_mem"
  }
}

EOF

}
