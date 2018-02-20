From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:37 +1100
Subject: [lustre-devel] [PATCH 00/21] staging: assorted lustre clean-up
Message-ID: <151909308778.25814.9912662268627044409.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Following are assorted patches which clean up parts of lustre.
One or two tiny buglets are fixed, but mostly the patches
just make the code more readable, often by removing distractions.

The first several patches remove content from libcfs, completely
removing 3 files.
There are some list_for_each improvements in ptlrpc, and some
code simplification in fid.
Finally a small simplification in socklnd.

(lnd ?? Lustre Networking Domain??)

Thanks,
NeilBrown


---

NeilBrown (21):
      staging: lustre: replace all CFS_CAP_* macros with CAP_*
      staging: lustre: opencode cfs_cap_{raise,lower,raised}
      staging: lustre: remove linux-curproc.c
      staging: lustre: remove unnecessary cfs_block_allsigs() calls
      staging: lustre: lnet: remove cfs_block_allsigs calls.
      staging: lustre: simplify linux-prim.c
      staging: lustre: improve API and implementation of blocking signals.
      staging: lustre: make signal-blocking functions inline
      staging: lustre: discard libcfs_kvzalloc_cpt()
      staging: lustre: discard lu_buf allocation library.
      staging: lustre: improve some libcfs_kvzalloc calls.
      staging: lustre: discard libcfs_kvzalloc and linux-mem.c
      staging: lustre: remove phantom struct cfs_crypto_hash_desc
      staging: lustre: fix assorted checkpatch errors
      staging: lustre: ptlrpc: list_for_each improvements.
      staging: lustre: fid: convert lcs_mutex to a spinlock
      staging: lustre: fid: use wait_event_cmd()
      staging: lustre: fid: remove seq_fid_alloc_fini() and simplify
      staging: lustre: fid: fix up debugfs access to ->lcs_space
      staging: lustre: fid: perform sanity checks before commiting
      staging: lustre: socklnd: simplify ksnc_rx_iov_space


 .../staging/lustre/include/linux/libcfs/curproc.h  |   37 ++-----
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   27 +++--
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |   11 +-
 drivers/staging/lustre/include/linux/lnet/api.h    |    1 
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    6 -
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   11 --
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   10 --
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    2 
 drivers/staging/lustre/lnet/libcfs/Makefile        |    4 -
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |    2 
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   29 ++---
 .../lustre/lnet/libcfs/linux/linux-curproc.c       |  108 -------------------
 .../staging/lustre/lnet/libcfs/linux/linux-mem.c   |   51 ---------
 .../staging/lustre/lnet/libcfs/linux/linux-prim.c  |  113 --------------------
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   15 +--
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |   10 +-
 drivers/staging/lustre/lnet/lnet/router.c          |    2 
 drivers/staging/lustre/lnet/selftest/timer.c       |    2 
 drivers/staging/lustre/lustre/fid/fid_request.c    |  106 ++++++-------------
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |   44 +++++---
 drivers/staging/lustre/lustre/include/lu_object.h  |    7 -
 drivers/staging/lustre/lustre/include/lustre_fid.h |    2 
 drivers/staging/lustre/lustre/include/lustre_lib.h |   18 ++-
 drivers/staging/lustre/lustre/include/lustre_sec.h |    3 -
 drivers/staging/lustre/lustre/include/obd_class.h  |    8 +
 .../staging/lustre/lustre/include/obd_support.h    |    2 
 drivers/staging/lustre/lustre/llite/dcache.c       |    2 
 drivers/staging/lustre/lustre/llite/dir.c          |   10 +-
 drivers/staging/lustre/lustre/llite/file.c         |   12 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    8 +
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    8 +
 drivers/staging/lustre/lustre/llite/xattr.c        |    2 
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    4 -
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    2 
 drivers/staging/lustre/lustre/lov/lov_io.c         |    2 
 drivers/staging/lustre/lustre/lov/lov_lock.c       |    2 
 drivers/staging/lustre/lustre/lov/lov_object.c     |    4 -
 drivers/staging/lustre/lustre/lov/lov_pack.c       |    2 
 drivers/staging/lustre/lustre/lov/lov_request.c    |    2 
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    2 
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    6 +
 drivers/staging/lustre/lustre/obdclass/linkea.c    |   16 ++-
 .../lustre/lustre/obdclass/linux/linux-module.c    |    4 -
 drivers/staging/lustre/lustre/obdclass/llog.c      |   22 ++--
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   70 ------------
 .../lustre/lustre/obdclass/lustre_handles.c        |    4 -
 .../staging/lustre/lustre/obdecho/echo_client.c    |    8 +
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    4 -
 drivers/staging/lustre/lustre/osc/osc_page.c       |    2 
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   93 +++++-----------
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   34 ++----
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |    2 
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |    8 -
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   15 +--
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |   28 ++---
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    4 -
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |    4 -
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c    |    8 +
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |    8 +
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   27 ++---
 62 files changed, 295 insertions(+), 769 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c

--
Signature
