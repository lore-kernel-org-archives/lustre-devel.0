From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 14 Feb 2017 12:06:30 -0500
Subject: [lustre-devel] New tag 2.9.53
Message-ID: <681B1366-BADC-4E28-A814-6B84C1C26BFD@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I tagged new tag 2.9.53 in the Lustre development branch.

   Here's the changelog.

Aditya Pandit (1):
      LU-8702 tests: parallel execution of IOR and MDTEST added.

Alex Zhuravlev (3):
      LU-8972 osp: skip subsequent orphan cleanups
      LU-7910 osd: do not lookup child objects in osd_dir_insert()
      LU-8928 osd: convert osd-zfs to reference dnode, not db

Alexey Lyashkov (2):
      LU-8411 ofd: handle last_rcvd file can't update properly
      LU-8995 tests: set debug size correctly

Amir Shehata (30):
      LU-7734 lnet: Multi-Rail local NI split
      LU-7734 lnet: Multi-Rail peer split
      LU-7734 lnet: Multi-Rail local_ni/peer_ni selection
      LU-7734 lnet: configure peers from DLC
      LU-7734 lnet: configure local NI from DLC
      LU-7734 lnet: NUMA support
      LU-7734 lnet: Primary NID and traffic distribution
      LU-7734 lnet: handle non-MR peers
      LU-7734 lnet: handle N NIs to 1 LND peer
      LU-7734 lnet: rename LND peer to peer_ni
      LU-7734 lnet: peer/peer_ni handling adjustments
      LU-7734 lnet: proper cpt locking
      LU-7734 lnet: protect peer_ni credits
      LU-7734 lnet: simplify and fix lnet_select_pathway()
      LU-7734 lnet: Fix lnet_msg_free()
      LU-7734 lnet: configuration fixes
      LU-7734 lnet: fix lnet_select_pathway()
      LU-7734 lnet: Routing fixes part 1
      LU-7734 lnet: Routing fixes part 2
      LU-7734 lnet: fix routing selection
      LU-7734 lnet: Fix crash in router_proc.c
      LU-7734 lnet: minor fixes
      LU-7734 lnet: fix string.h header inclusion
      LU-7734 lnet: fix NULL access in lnet_peer_aliveness_enabled
      LU-7734 lnet: Enhance DLC ip2nets
      LU-7734 lnet: rename peer key_nid to prim_nid
      LU-7734 lnet: cpt locking
      LU-7734 lnet: Fix setting numa range
      LU-7734 lnet: multi-rail feature
      LU-9078 lnet: Fix route hops print

Andreas Dilger (1):
      LU-9073 gss: quiet insecure key file warning

Artem Blagodarenko (1):
      LU-8974 osd-ldiskfs: increase supported ldiskfs fs size

Aya Mahfouz (1):
      LU-4423 libcfs: remove IS_PO2 and __is_po2

Bob Glossman (3):
      LU-8954 kernel: kernel update [SLES12 SP1 3.12.67-60.64.24]
      LU-9030 kernel: kernel update RHEL7.3 [3.10.0-514.6.1.el7]
      LU-9029 kernel: kernel update [SLES12 SP2 4.4.38-93]

Chennaiah Palla (2):
      LU-8865 tests: add fs_test test
      LU-8903 tests: racer test_1 to drop all error messages

Dmitry Eremin (1):
      LU-9032 tests: syntax error in cleanup_test32_mount

Doug Oucharek (1):
      LU-7734 lnet: Add peer_ni and NI stats for DLC

Fan Yong (1):
      LU-8900 mgs: use reference count for fs_db

Gabriele Paciucci (1):
      LU-8457 pacemaker: Pacemaker script to monitor LNet

Hongchao Zhang (1):
      LU-9034 mgc: relate sptlrpc & params to MGC

Jadhav Vikram (1):
      LU-8687 tests: list pool on mds when mgs is separate

James Nunez (2):
      LU-6455 tests: Re-enable replay-vbr and replay-single tests
      LU-6319 tests: Resume parallel-grouplock testing

James Simmons (10):
      LU-7734 lnet: power8 compile fix
      LU-6245 libcfs: use libcfs_private.h only for kernel space
      LU-9019 mdt: use ktime_t for calculating elapsed time
      LU-8602 gss: Support GSS on linux 4.6+ kernels
      LU-7734 gnilnd: update GNI lnd driver to handle multirail api changes
      LU-9019 o2iblnd: use 64-bit ibn_incarnation computation
      LU-8066 obdclass: move lustre server sysctl to sysfs
      LU-6245 libcfs: replace IS_PO2 with is_power_of_2 in server code
      LU-9019 osd: migrate osd-ldiskfs thandle stats to 64 bit time
      LU-8843 client: fix all less than 0 comparison for unsigned values

Jian Yu (1):
      LU-9045 osp: Revert "LU-8840 osp: handle EA cache properly"

Jinshan Xiong (1):
      LU-8979 ldlm: disable brw lock request in recovery

Nathaniel Clark (1):
      LU-4121 tests: Enable zfs tests dependent on ost,mgs ordering

Niu Yawei (1):
      LU-9033 llite: don't zero timestamps internally

Olaf Weber (3):
      LU-7734 lnet: fix lnet_peer_table_cleanup_locked()
      LU-7734 lnet: double free in lnet_add_net_common()
      LU-7734 lnet: set primary NID in ptlrpc_connection_get()

Oleg Drokin (3):
      LU-8066 ldlm: move /proc/fs/lustre/ldlm to sysfs
      LU-8066 obdclass: Get rid of remaining /proc/sys/lustre plumbing
      New tag 2.9.53

Parinay Kondekar (1):
      LU-1573 recovery: Avoid data corruption for DIO during FOFB

Qian Yingjin (1):
      LU-5620 ptlrpc: Add QoS for opcode in NRS-TBF

Quentin Bouget (1):
      LU-8382 hsm: reorder coordinator's cleanup functions

Sonia Sharma (1):
      LU-8769 lnet: removal of obsolete LNDs

Stephen Champion (1):
      LU-7734 lnet: Update lnetctl usage

Steve Guminski (2):
      LU-6210 lnet: Change positional struct initializers to C99
      LU-6210 gss: Change positional struct initializers to C99

Vladimir Saveliev (1):
      LU-8420 ldlm: take at_current change into account on prolong

Wei Liu (1):
      LU-9041 test: Add version check to sanity test_402

Yang Sheng (1):
      LU-9031 osd: handle jinode change for ldiskfs


Bye,
    Oleg
