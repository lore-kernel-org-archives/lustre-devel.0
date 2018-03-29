From: NeilBrown <neilb@suse.com>
Date: Thu, 29 Mar 2018 15:26:48 +1100
Subject: [lustre-devel] [PATCH 00/17] staging: Assorted lustre cleanup
Message-ID: <152229732768.27689.4800156943561963977.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

I'm currently working on converting lustre to use
rhashtables instead of its own resizeable hash tables.
That is progressing well, but I need some changes to
rhashtable first, and that will take a little while.
So here are some other patches.
Some are cleanups related to hashtables,
some are related to measuring time in jiffies
and some are random other things I found as I was looking
at stuff.

James, if this jiffie stuff conflicts with your time-keeping stuff, we
can just drop it.  Last time I cleaned up jiffie-related code you
said it didn't conflict significantly, so I'm hoping this won't
either.

Thanks,
NeilBrown


---

NeilBrown (17):
      staging: lustre: remove invariant in cl_io_read_ahead()
      staging: lustre: remove unused ldlm_completion_ast_async()
      staging: lustre: LNET excludes USERIO
      staging: lustre: remove unused hash tables.
      staging: lustre: remove unneeded include.
      staging: lustre: tidy up ldlm_resource_putref()
      staging: lustre: ldlm: free resource when ldlm_lock_create() fails.
      staging: lustre: add container_of_safe()
      staging: lustre: cfs_time_current() -> jiffies.
      staging: lustre: libcfs: discard cfs_time_add/sub
      staging: lustre: libcfs: discard cfs_time_shift().
      staging: lustre: libcfs: discard cfs_time_after()
      staging: lustre: libcfs: remove cfs_timeout_cap()
      staging: lustre: discard cfs_duration_sec()
      staging: lustre: discard cfs_time_before_64()
      staging: lustre: discard linux-time.h
      staging: lustre: remove cruft from libcfs/linux/libcfs.h


 .../staging/lustre/include/linux/libcfs/curproc.h  |    2 
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   17 +--
 .../lustre/include/linux/libcfs/libcfs_time.h      |   79 ---------------
 .../lustre/include/linux/libcfs/linux/libcfs.h     |   18 ---
 .../lustre/include/linux/libcfs/linux/linux-time.h |  103 --------------------
 drivers/staging/lustre/lnet/Kconfig                |    2 
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   32 +++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    6 +
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   17 ++-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   15 +--
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   87 ++++++++---------
 drivers/staging/lustre/lnet/libcfs/debug.c         |    2 
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   12 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   14 +--
 drivers/staging/lustre/lnet/lnet/net_fault.c       |   40 ++++----
 drivers/staging/lustre/lnet/lnet/peer.c            |    2 
 drivers/staging/lustre/lnet/lnet/router.c          |   17 ++-
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   13 +--
 drivers/staging/lustre/lnet/selftest/conrpc.c      |   14 +--
 drivers/staging/lustre/lnet/selftest/console.c     |    4 -
 drivers/staging/lustre/lnet/selftest/framework.c   |    2 
 drivers/staging/lustre/lnet/selftest/timer.c       |    4 -
 drivers/staging/lustre/lustre/include/cl_object.h  |   10 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |    6 +
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   13 ---
 .../staging/lustre/lustre/include/lustre_export.h  |    7 -
 drivers/staging/lustre/lustre/include/lustre_net.h |    7 +
 drivers/staging/lustre/lustre/include/obd_class.h  |   10 +-
 .../staging/lustre/lustre/include/obd_support.h    |   18 ---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   11 --
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   22 +---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    5 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   66 ++-----------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   25 ++---
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    4 -
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |    2 
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   12 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |    4 -
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    8 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    2 
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |   18 ++-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    2 
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 
 drivers/staging/lustre/lustre/lov/lov_request.c    |    4 -
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |    1 
 drivers/staging/lustre/lustre/obdclass/cl_object.c |    1 
 drivers/staging/lustre/lustre/obdclass/genops.c    |    2 
 .../lustre/lustre/obdclass/lprocfs_status.c        |   12 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    8 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |    2 
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    2 
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   10 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    2 
 drivers/staging/lustre/lustre/osc/osc_io.c         |    2 
 drivers/staging/lustre/lustre/osc/osc_object.c     |   11 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |    4 -
 drivers/staging/lustre/lustre/osc/osc_request.c    |    6 +
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    4 -
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   10 +-
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |   23 ++--
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    6 +
 include/linux/kernel.h                             |   16 +++
 66 files changed, 284 insertions(+), 606 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h

--
Signature
