From: =?ISO-8859-1?B?MTAwMDA=?= <10000@candesoft.com>
Date: Sat, 5 Mar 2016 14:08:55 +0800
Subject: [lustre-devel] Bug found: Missing lnetctl command on any
	recentdaily built package
In-Reply-To: <51102781-6DE8-418E-B236-F1ADAA287986@intel.com>
References: <tencent_4A8CFD8250BEDB3A3649365E@qq.com>
	<56D9E0EB.1070508@llnl.gov>
	<51102781-6DE8-418E-B236-F1ADAA287986@intel.com>
Message-ID: <tencent_457D7F416B6B8DD22BD6CC15@qq.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 5, 2016, at 11:14 AM, Drokin, Oleg wrote:

> llmount.sh does not appear to need lnetctl (I use the llmount.sh,
> and I do not have lnetctl built). 

I would say it may be needed at some situation. I can repeat this situation at VirtualBox with the following steps:
1. Create a virtual machine with two network interface card, and the first one set to NAT network while the second one set to Host-Only network.
2. Install CentOS 7.2 on it.
3.  run "ip addr" you may get as below:

     	1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
	   ...
	    inet 127.0.0.1/8 scope host lo
	   ...
	2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
	   ...
	    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
	   ...
	3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
	   ...
	    inet 192.168.56.101/24 brd 192.168.56.255 scope global dynamic enp0s8
	   ...

     As it shows you have the NAT network at first NIC and the host-only network at second.
     Now modify /etc/hostname with a name you specified (such as "node1") and modify /etc/hosts adding the host-only IP address with that hostname. you may reboot the machine after modifing to take effect.
     After modify these two files, if you run 'cat' to them, you should get something like as below:

     	[eteced at node1 ~]$ cat /etc/hostname 
	node1
	[eteced at node1 ~]$ cat /etc/hosts
	127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
	::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
	192.168.56.101  node1
	[eteced at node1 ~]$ 

4. Download the latest build rpms (#3330) from https://build.hpdd.intel.com/job/lustre-master/ and install them. (You may need reboot to use the kernel which just been installed)
5. Simply run "llmount.sh" at /lib64/lustre/tests/llmount.sh, it would like as below:

	[root at node1 eteced]# /lib64/lustre/tests/llmount.sh
	Stopping clients: node1 /mnt/lustre (opts:)
	Stopping clients: node1 /mnt/lustre2 (opts:)
	Loading modules from /lib64/lustre/tests/..
	detected 1 online CPUs by sysfs
	libcfs will create CPU partition based on online CPUs
	debug=vfstrace rpctrace dlmtrace neterror ha config                   ioctl super lfsck
	subsystem_debug=all -lnet -lnd -pinger
	quota/lquota options: 'hash_lqs_cur_bits=3'
	Formatting mgs, mds, osts
	Format mds1: /tmp/lustre-mdt1
	Format ost1: /tmp/lustre-ost1
	Format ost2: /tmp/lustre-ost2
	Checking servers environments
	Checking clients node1 environments
	Loading modules from /lib64/lustre/tests/..
	detected 1 online CPUs by sysfs
	libcfs will create CPU partition based on online CPUs
	debug=vfstrace rpctrace dlmtrace neterror ha config                   ioctl super lfsck
	subsystem_debug=all -lnet -lnd -pinger
	Setup mgs, mdt, osts
	Starting mds1:   -o loop /tmp/lustre-mdt1 /mnt/mds1
	Started lustre-MDT0000
	Starting ost1:   -o loop /tmp/lustre-ost1 /mnt/ost1
	mount.lustre: mount /dev/loop1 at /mnt/ost1 failed: Connection timed out

   And then you may run 'dmesg', it shows:

   	...
	[  134.960367] LNetError: 120-3: Refusing connection from 192.168.56.101 for 192.168.56.101 at tcp: No matching NI
	[  134.960666] LNetError: 10438:0:(socklnd_cb.c:1723:ksocknal_recv_hello()) Error -104 reading HELLO from 192.168.56.101
	[  134.961040] LNetError: 11b-b: Connection to 192.168.56.101 at tcp at host 192.168.56.101 on port 988 was reset: is it running a compatible version of Lustre and is 192.168.56.101 at tcp one of its NIDs?
	[  139.960163] Lustre: 10446:0:(client.c:2063:ptlrpc_expire_one_request()) @@@ Request sent has timed out for slow reply: [sent 1457156893/real 1457156893]  req at ffff88020433a600 x1527939743088740/t0(0) o250->MGC192.168.56.101 at tcp@192.168.56.101 at tcp:26/25 lens 520/544 e 0 to 1 dl 1457156898 ref 1 fl Rpc:XN/0/ffffffff rc 0/-1
	[  139.960500] Lustre: lustre-MDT0000: Connection restored to 10.0.2.15 at tcp (at 0 at lo)
	[  139.960684] LNetError: 120-3: Refusing connection from 192.168.56.101 for 192.168.56.101 at tcp: No matching NI
	[  139.961892] LNetError: 10439:0:(socklnd_cb.c:1723:ksocknal_recv_hello()) Error -104 reading HELLO from 192.168.56.101
	[  139.962902] LNetError: 11b-b: Connection to 192.168.56.101 at tcp at host 192.168.56.101 on port 988 was reset: is it running a compatible version of Lustre and is 192.168.56.101 at tcp one of its NIDs?
	[  144.971200] LustreError: 15f-b: lustre-OST0000: cannot register this server with the MGS: rc = -110. Is the MGS running?
	[  144.972325] LustreError: 11686:0:(obd_mount_server.c:1798:server_fill_super()) Unable to start targets: -110
	[  144.974060] LustreError: 11686:0:(obd_mount_server.c:1512:server_put_super()) no obd lustre-OST0000
	[  144.974866] LustreError: 11686:0:(obd_mount_server.c:140:server_deregister_mount()) lustre-OST0000 not registered
	[  145.011302] Lustre: server umount lustre-OST0000 complete
	[  145.011302] LustreError: 11686:0:(obd_mount.c:1426:lustre_fill_super()) Unable to mount  (-110)

   Since there are no 'lnetctl' command line tools, you may have to add a conf at /etc/modprobe.d/ with line "options lnet networks=tcp0(enp0s8)" , then you need to run 'llmountcleanup.sh' before running 'llmount.sh' again. Just like below:

     	[root at node1 eteced]# /lib64/lustre/tests/llmountcleanup.sh
	Stopping clients: node1 /mnt/lustre (opts:-f)
	Stopping clients: node1 /mnt/lustre2 (opts:-f)
	Stopping /mnt/mds1 (opts:-f) on node1
	modules unloaded.
	[root at node1 eteced]# /lib64/lustre/tests/llmount.sh
	Stopping clients: node1 /mnt/lustre (opts:)
	Stopping clients: node1 /mnt/lustre2 (opts:)
	Loading modules from /lib64/lustre/tests/..
	detected 1 online CPUs by sysfs
	libcfs will create CPU partition based on online CPUs
	debug=vfstrace rpctrace dlmtrace neterror ha config                   ioctl super lfsck
	subsystem_debug=all -lnet -lnd -pinger
	quota/lquota options: 'hash_lqs_cur_bits=3'
	Formatting mgs, mds, osts
	Format mds1: /tmp/lustre-mdt1
	Format ost1: /tmp/lustre-ost1
	Format ost2: /tmp/lustre-ost2
	Checking servers environments
	Checking clients node1 environments
	Loading modules from /lib64/lustre/tests/..
	detected 1 online CPUs by sysfs
	libcfs will create CPU partition based on online CPUs
	debug=vfstrace rpctrace dlmtrace neterror ha config                   ioctl super lfsck
	subsystem_debug=all -lnet -lnd -pinger
	Setup mgs, mdt, osts
	Starting mds1:   -o loop /tmp/lustre-mdt1 /mnt/mds1
	Started lustre-MDT0000
	Starting ost1:   -o loop /tmp/lustre-ost1 /mnt/ost1
	Started lustre-OST0000
	Starting ost2:   -o loop /tmp/lustre-ost2 /mnt/ost2
	Started lustre-OST0001
	Starting client: node1:  -o user_xattr,flock node1 at tcp:/lustre /mnt/lustre
	Using TIMEOUT=20
	seting jobstats to procname_uid
	Setting lustre.sys.jobid_var from disable to procname_uid
	Waiting 90 secs for update
	Updated after 3s: wanted 'procname_uid' got 'procname_uid'
	disable quota as required
	[root at node1 eteced]# 

It seems successfully running "llmount.sh". Although these steps are producing at a virtual machine, I think the key point to truggle the bug is that you have two network card, and the hostname is set to the second rather than the first (at /etc/hosts or some other name resolving settings).

I will post it at jira also.

Yingdi Guo
