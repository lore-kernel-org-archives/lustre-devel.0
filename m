From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:49:48 -0500
Subject: [lustre-devel] [PATCH 00/25] Lustre cleanups continued
Message-ID: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

These are the cleanup patches that were not applied from the previous
patch set due to a missing NFS/fhandle fix that is now applied.
Also some defines removal and such.

Please apply.

Oleg Drokin (25):
  staging/lustre/llite: Fix style vs open parenthesis alignment
  staging/lustre/include: Fix style of function declarations
  staging/lustre/fld: Fix style vs open parenthesis alignment
  staging/lustre: Remove unused liblustre_check_services prototype
  staging/lustre: Remove unused lustre_build_lock_params()
  staging/lustre: Convert ptlrpc_at_check_timed to void
  staging/lustre: Remove misleading liblustre comments.
  staging/lustre: Remove liblustre references from explanations
  staging/lustre/lmv: Remove commented out MDS selection policies
  staging/lustre: F_SETLKW64 F_SETLK64 F_GETLK64 are always defined
  staging/lustre: MS_POSIXACL is always defined, don't check for it
  staging/lustre: Remove RELEASEPAGE_ARG_TYPE compat macro
  staging/lustre: NEED_QUOTA_DEFS is never defined, drop it.
  staging/lustre/ptlrpc: Fix style vs open parenthesis alignment
  staging/lustre/osc: Fix style vs open parenthesis alignment
  staging/lustre/obdclass: Fix style vs open parenthesis alignment
  staging/lustre/lov: Fix style vs open parenthesis alignment
  staging/lustre/mdc: Fix style vs open parenthesis alignment
  staging/lustre/mgc: Fix style vs open parenthesis alignment
  staging/lustre/obdecho: Fix style vs open parenthesis alignment
  staging/lustre/lmv: Fix style vs open parenthesis alignment
  staging/lustre: Fix lines that start with spaces
  staging/lustre: Rework MAX_DIO_SIZE macro
  staging/lustre: Remove unneeded {} in lprocfs_stats_unlock()
  staging/lustre/ptlrpc: Fix ENABLE_PINGER ifdef

 drivers/staging/lustre/lustre/fld/fld_cache.c      |  14 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |  17 +-
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |   3 +-
 drivers/staging/lustre/lustre/include/cl_object.h  | 414 ++++++++++-----------
 .../staging/lustre/lustre/include/lprocfs_status.h |  16 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |  10 +-
 .../lustre/lustre/include/lustre/lustre_user.h     |  16 -
 drivers/staging/lustre/lustre/include/lustre_cfg.h |   2 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   4 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |   2 +-
 .../staging/lustre/lustre/include/lustre_lite.h    |  50 +--
 drivers/staging/lustre/lustre/include/lustre_net.h |  20 +-
 .../lustre/lustre/include/lustre_req_layout.h      |   4 +-
 drivers/staging/lustre/lustre/include/lustre_sec.h | 128 +++----
 drivers/staging/lustre/lustre/include/obd.h        |   8 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |  14 +-
 drivers/staging/lustre/lustre/llite/dcache.c       |   3 +-
 drivers/staging/lustre/lustre/llite/dir.c          |   6 +-
 drivers/staging/lustre/lustre/llite/file.c         |  78 ++--
 drivers/staging/lustre/lustre/llite/llite_close.c  |   5 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  11 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  32 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   4 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  18 +-
 drivers/staging/lustre/lustre/llite/llite_rmtacl.c |   8 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  16 +-
 drivers/staging/lustre/lustre/llite/namei.c        |   8 +-
 drivers/staging/lustre/lustre/llite/rw.c           |   6 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  42 +--
 drivers/staging/lustre/lustre/llite/statahead.c    |  18 +-
 drivers/staging/lustre/lustre/llite/super25.c      |   4 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |   2 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  13 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  14 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  12 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   8 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  19 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   2 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   4 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  73 +---
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  87 +++--
 drivers/staging/lustre/lustre/lov/lov_ea.c         |   2 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |   6 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |   2 +-
 drivers/staging/lustre/lustre/lov/lov_lock.c       |   7 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  35 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     |  40 +-
 drivers/staging/lustre/lustre/lov/lov_offset.c     |   3 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |   7 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |   3 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |   6 +-
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |   2 +-
 drivers/staging/lustre/lustre/lov/lovsub_page.c    |   2 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c      |  16 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   2 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  26 +-
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  12 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  28 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  20 +-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |  21 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  11 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  10 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   3 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  26 +-
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |   8 +-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |   4 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        | 125 +++----
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   3 +-
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |   2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |   6 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   8 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |  22 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |  20 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  18 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   5 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  30 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  37 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  17 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  40 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  49 +--
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |  35 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  15 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |  19 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |   2 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |   5 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   9 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  83 ++---
 94 files changed, 917 insertions(+), 1178 deletions(-)

-- 
2.1.0
