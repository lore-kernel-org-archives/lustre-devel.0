From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Jul 2018 16:23:04 +1000
Subject: [lustre-devel] [PATCH 0/9] lustre improvements
Message-ID: <153232696720.26222.9658151633697867322.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is an ad-hoc collection of improvments and bug fixes
(mostly my bugs :-( )
Most interesting is  that handling of 'mount' is moved
from obdclass to llite, which seems to be a more fitting
place for it.

Thanks,
NeilBrown

---

NeilBrown (9):
      lustre: merge linux-debug.c into debug.c
      lustre: llog: use GFP_KERNEL for all allocations.
      lustre: move server_name2index to obd_config.c
      lustre: move lustre_check_exclusion to obd_config.c
      lustre: move filesystem mounting from obdclass to llite
      lustre: hold ptlrpc active for lustre_start_mgc()
      lustre: ll_fill_super() must put sb on all failure paths.
      lustre: ensure libcfs is set up for ioctls.
      lustre: lnet: discard LNET_LOCK()


 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    8 
 drivers/staging/lustre/lnet/libcfs/Makefile        |    1 
 drivers/staging/lustre/lnet/libcfs/debug.c         |   86 +
 drivers/staging/lustre/lnet/libcfs/linux-debug.c   |  142 --
 drivers/staging/lustre/lnet/libcfs/module.c        |    3 
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |    4 
 drivers/staging/lustre/lnet/selftest/rpc.c         |    2 
 drivers/staging/lustre/lustre/include/obd_class.h  |    7 
 drivers/staging/lustre/lustre/llite/Makefile       |    2 
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   16 
 drivers/staging/lustre/lustre/llite/mount.c        | 1216 ++++++++++++++++++
 drivers/staging/lustre/lustre/llite/super25.c      |    8 
 drivers/staging/lustre/lustre/obdclass/Makefile    |    2 
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    6 
 drivers/staging/lustre/lustre/obdclass/llog.c      |    6 
 .../staging/lustre/lustre/obdclass/obd_config.c    |  111 ++
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 1353 --------------------
 19 files changed, 1440 insertions(+), 1539 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-debug.c
 create mode 100644 drivers/staging/lustre/lustre/llite/mount.c
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/obd_mount.c

--
Signature
