From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 00/30] staging: lustre: tidy up - module init
 and includes
Message-ID: <152687724799.24196.7718555295926047576.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This series addresses two particular issues, and includes a bunch
of related tidy-ups as well.

1/ there were a few reports of lustre crashing because a char-special
 couldn't be registered.  We fixed the char-special registration so it
 won't fail, but the crash it still bad.
 The root cause is that most modules assume libcfs has initialised
 properly without checking that it did.  When separate modules are
 used, there is no need to check.  When all is compiled into the
 kernel, the need does arise.
 So this series fixes that and also makes sure no module registers any
 service unless it initializes properly.

2/ As James Simmons recently noted, dumping all the extra headers
 from linux/libcfs.h into libcfs.h isn't a suitable end-game.
 This series completes the work started at that time by removing
 all the includes from libcfs.h.  I did this over a series of patches
 as it was easier to work that way.  They don't really need much review,
 just compile testing which I have done (both with and without
 modules, and with and without SMP).

There is also come other cleaning up of include file content in there.

Sorry the series is so long, but most of it should be easy to review.

Thanks,
NeilBrown

---

NeilBrown (30):
      staging: lustre: osc: tidy up osc_init()
      staging: lustre: refactor libcfs initialization.
      staging: lustre: move files out of lustre/lnet/libcfs/linux/
      staging: lustre: rename cfs_cpt_table to cfs_cpt_tab
      staging: lustre: remove conditional compilation from libcfs_cpu.c
      staging: lustre: remove current_pid() and current_comm()
      staging: lustre: simplify capability dropping.
      staging: lustre: discard cfs_cap_t, use kernel_cap_t
      staging: lustre: discard LOWEST_BIT_SET()
      staging: lustre: discard CFS_TICK
      staging: lustre: move LERRCHKSUM() to libcfs_debug.h
      staging: lustre: discard cfs_block_sigsinv()
      staging: lustre: replace libcfs_register_ioctl with a blocking notifier_chain
      staging: lustre: clean up __LIBCFS_H macro
      staging: lustre: make lnet_debugfs_symlink_def local to libcfs/modules.c
      staging: lustre: move lnet_debug_log_upcall declaration to tracefile.h
      staging: lustre: move RESV_PORT definitions to lnet/lib-lnet.h
      staging: lustre: replace memory_presure funcitons by standard interfaces.
      staging: lustre: discard libcfs_prim.h
      staging: lustre: start moving includes out of libcfs.h
      staging: lustre: don't include libcfs.h in lnet/lib-lnet.h
      staging: lustre: remove libcfs_all.h includes from lnet/klnd
      staging: lustre: remove libcfs_all.h from includes lustre/lnet
      staging: lustre: remove libcfs_all.h from lustre/include/*.h
      staging: lustre: remove libcfs_all.h from remaining .h files.
      staging: lustre: remove libcfs_all from ptlrpc
      staging: lustre: remove libcfs_all.h from fid, fld, obdclass
      staging: lustre: remove remaining libcfs_all.h includes from lustre/lustre
      staging: lustre: move all libcfs_all includes except in lustre/lnet/libcfs/
      staging: lustre: remove libcfs_all.h


 .../staging/lustre/include/linux/libcfs/curproc.h  |   83 ----
 .../staging/lustre/include/linux/libcfs/libcfs.h   |  128 +-----
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |   39 +-
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |    3 
 .../lustre/include/linux/libcfs/libcfs_debug.h     |    8 
 .../lustre/include/linux/libcfs/libcfs_fail.h      |    3 
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    3 
 .../lustre/include/linux/libcfs/libcfs_prim.h      |   82 ----
 .../lustre/include/linux/libcfs/libcfs_string.h    |    2 
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    8 
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    6 
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    1 
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    4 
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    3 
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   11 
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    1 
 drivers/staging/lustre/lnet/libcfs/Makefile        |   17 -
 drivers/staging/lustre/lnet/libcfs/debug.c         |    7 
 drivers/staging/lustre/lnet/libcfs/fail.c          |    4 
 drivers/staging/lustre/lnet/libcfs/hash.c          |    5 
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |   97 +---
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |    3 
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c    |    6 
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |    6 
 .../lustre/lnet/libcfs/linux-crypto-adler.c        |  139 ++++++
 drivers/staging/lustre/lnet/libcfs/linux-crypto.c  |  447 ++++++++++++++++++++
 drivers/staging/lustre/lnet/libcfs/linux-crypto.h  |   30 +
 drivers/staging/lustre/lnet/libcfs/linux-debug.c   |  142 ++++++
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   |  258 ++++++++++++
 .../lustre/lnet/libcfs/linux/linux-crypto-adler.c  |  139 ------
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |  443 --------------------
 .../lustre/lnet/libcfs/linux/linux-crypto.h        |   30 -
 .../staging/lustre/lnet/libcfs/linux/linux-debug.c |  144 ------
 .../lustre/lnet/libcfs/linux/linux-tracefile.c     |  257 -----------
 drivers/staging/lustre/lnet/libcfs/module.c        |  156 +++----
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   15 -
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |   11 
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    6 
 drivers/staging/lustre/lnet/lnet/config.c          |    1 
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    2 
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    2 
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |    1 
 drivers/staging/lustre/lnet/lnet/module.c          |   42 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    3 
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    3 
 drivers/staging/lustre/lnet/selftest/conctl.c      |   28 +
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    1 
 drivers/staging/lustre/lnet/selftest/conrpc.h      |    1 
 drivers/staging/lustre/lnet/selftest/console.c     |   11 
 drivers/staging/lustre/lnet/selftest/console.h     |    4 
 drivers/staging/lustre/lnet/selftest/framework.c   |    2 
 drivers/staging/lustre/lnet/selftest/module.c      |    6 
 drivers/staging/lustre/lnet/selftest/selftest.h    |    1 
 drivers/staging/lustre/lustre/fid/fid_internal.h   |    1 
 drivers/staging/lustre/lustre/fid/fid_lib.c        |    1 
 drivers/staging/lustre/lustre/fid/fid_request.c    |    7 
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |    1 
 drivers/staging/lustre/lustre/fld/fld_cache.c      |    1 
 drivers/staging/lustre/lustre/fld/fld_internal.h   |    1 
 drivers/staging/lustre/lustre/fld/fld_request.c    |    7 
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |    1 
 .../staging/lustre/lustre/include/lprocfs_status.h |    2 
 .../staging/lustre/lustre/include/lustre_compat.h  |    1 
 .../staging/lustre/lustre/include/lustre_disk.h    |    1 
 drivers/staging/lustre/lustre/include/lustre_fld.h |    1 
 .../staging/lustre/lustre/include/lustre_handles.h |    2 
 .../staging/lustre/lustre/include/lustre_import.h  |    1 
 .../staging/lustre/lustre/include/lustre_intent.h  |    2 
 drivers/staging/lustre/lustre/include/lustre_lib.h |   22 +
 drivers/staging/lustre/lustre/include/lustre_mds.h |    1 
 .../lustre/include/lustre_patchless_compat.h       |    1 
 drivers/staging/lustre/lustre/include/lustre_sec.h |    2 
 drivers/staging/lustre/lustre/include/obd.h        |    4 
 drivers/staging/lustre/lustre/include/obd_class.h  |    2 
 .../staging/lustre/lustre/include/obd_support.h    |    1 
 drivers/staging/lustre/lustre/ldlm/l_lock.c        |    1 
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |    1 
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    1 
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    3 
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   11 
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    1 
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    1 
 drivers/staging/lustre/lustre/llite/dir.c          |    2 
 drivers/staging/lustre/lustre/llite/file.c         |    8 
 drivers/staging/lustre/lustre/llite/glimpse.c      |    1 
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    1 
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    3 
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   14 -
 drivers/staging/lustre/lustre/llite/namei.c        |    2 
 drivers/staging/lustre/lustre/llite/range_lock.c   |    1 
 drivers/staging/lustre/lustre/llite/range_lock.h   |    2 
 drivers/staging/lustre/lustre/llite/statahead.c    |    6 
 drivers/staging/lustre/lustre/llite/super25.c      |    4 
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    1 
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    2 
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   15 -
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |    2 
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    1 
 drivers/staging/lustre/lustre/lov/lov_merge.c      |    4 
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   11 
 drivers/staging/lustre/lustre/lov/lov_offset.c     |    2 
 drivers/staging/lustre/lustre/lov/lov_pool.c       |    2 
 drivers/staging/lustre/lustre/lov/lov_request.c    |    2 
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    4 
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   17 -
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    2 
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    9 
 drivers/staging/lustre/lustre/mgc/mgc_internal.h   |    1 
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    7 
 drivers/staging/lustre/lustre/obdclass/cl_object.c |    1 
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    1 
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    9 
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |    2 
 .../lustre/lustre/obdclass/linux/linux-module.c    |    1 
 drivers/staging/lustre/lustre/obdclass/llog.c      |    1 
 .../lustre/lustre/obdclass/lprocfs_counters.c      |    1 
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 
 drivers/staging/lustre/lustre/obdclass/lu_ref.c    |    2 
 .../lustre/lustre/obdclass/lustre_handles.c        |    1 
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    1 
 drivers/staging/lustre/lustre/obdclass/uuid.c      |    2 
 .../staging/lustre/lustre/obdecho/echo_client.c    |    7 
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    2 
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    2 
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    1 
 drivers/staging/lustre/lustre/osc/osc_request.c    |   46 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   14 -
 drivers/staging/lustre/lustre/ptlrpc/errno.c       |    1 
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    3 
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |    2 
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c    |    2 
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |    7 
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |    3 
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |    3 
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    2 
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |    2 
 .../staging/lustre/lustre/ptlrpc/ptlrpc_module.c   |    4 
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   14 -
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    2 
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   15 -
 141 files changed, 1528 insertions(+), 1693 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/curproc.h
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
 create mode 100644 drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c
 create mode 100644 drivers/staging/lustre/lnet/libcfs/linux-crypto.c
 create mode 100644 drivers/staging/lustre/lnet/libcfs/linux-crypto.h
 create mode 100644 drivers/staging/lustre/lnet/libcfs/linux-debug.c
 create mode 100644 drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-crypto-adler.c
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.h
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c

--
Signature
