From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:49:32 +1000
Subject: [lustre-devel] [PATCH 0/7] lustre: ad-hoc fixes
Message-ID: <153292249340.26496.13985174182824912332.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There is no real pattern here, just minor tidy-up and minor bug-fix.

Thanks,
NeilBrown


---

NeilBrown (7):
      lustre: use schedule_timeout_$state().
      lustre/libcfs: fix freeing after kmalloc failure.
      lustre/libfs: move debugfs registration from libcfs_setup back to libcfs_init
      lustre: give different tcd_lock types different classes.
      lustre/libcfs: discard cfs_trace_allocate_string_buffer()
      lustre: lnet: convert ni_refs to percpu_refcount.
      lustre: change TASK_NOLOAD to TASK_IDLE.


 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   11 +---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 -
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   12 ++---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    6 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   14 ++----
 drivers/staging/lustre/lnet/libcfs/fail.c          |    3 -
 drivers/staging/lustre/lnet/libcfs/hash.c          |    2 -
 drivers/staging/lustre/lnet/libcfs/module.c        |   14 +++---
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   49 +++++++++++---------
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |    1 
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    3 -
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   40 +++++++---------
 drivers/staging/lustre/lnet/lnet/config.c          |   13 +++--
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    4 +-
 drivers/staging/lustre/lnet/lnet/peer.c            |    3 -
 drivers/staging/lustre/lnet/lnet/router.c          |   19 ++------
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 -
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    3 -
 drivers/staging/lustre/lnet/selftest/rpc.c         |    3 -
 drivers/staging/lustre/lnet/selftest/selftest.h    |    3 -
 drivers/staging/lustre/lustre/include/lustre_mdc.h |    2 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    3 -
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    8 +--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    6 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    3 -
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    4 --
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    3 -
 27 files changed, 101 insertions(+), 135 deletions(-)

--
Signature
