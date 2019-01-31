From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:04 -0500
Subject: [lustre-devel] [PATCH 00/26] lustre: cleanups with no code changes
Message-ID: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

To prepare for lustre to leave staging the code needs to be
cleaned up to make it easier for others to examine our code.
This patch series does no real code changes but does the
following:

1) Replace all the UAPI types in the kernel only code. Once
   these patches are applied only the UAPI headers will have
   UAPI types.

2) The lustre code has massive amounts of white spacing. Remove
   the white spacing for variable declarations. Removing the
   white spacing in data structures and align the fields to
   make it easier to read. In a few patches remove access
   blank lines.

James Simmons (26):
  lnet: use kernel types for lnet core kernel code
  lnet: use kernel types for lnet klnd kernel code
  lnet: use kernel types for lnet selftest kernel code
  ptlrpc: use kernel types for kernel code
  lustre: use kernel types for lustre internal headers
  ldlm: use kernel types for kernel code
  obdclass: use kernel types for kernel code
  lustre: convert remaining code to kernel types
  lustre: cleanup white spaces in fid and fld layer
  ldlm: cleanup white spaces
  llite: cleanup white spaces
  lmv: cleanup white spaces
  lov: cleanup white spaces
  mdc: cleanup white spaces
  mgc: cleanup white spaces
  obdclass: cleanup white spaces
  obdecho: cleanup white spaces
  osc: cleanup white spaces
  ptlrpc: cleanup white spaces
  lustre: first batch to cleanup white spaces in internal headers
  lustre: second batch to cleanup white spaces in internal headers
  lustre: last batch to cleanup white spaces in internal headers
  libcfs: cleanup white spaces
  lnet: cleanup white spaces
  socklnd: cleanup white spaces
  o2iblnd: cleanup white spaces

 .../lustre/include/linux/libcfs/libcfs_debug.h     |  74 +-
 .../lustre/include/linux/libcfs/libcfs_fail.h      |   8 +-
 .../lustre/include/linux/libcfs/libcfs_private.h   |  56 +-
 .../lustre/include/linux/libcfs/libcfs_string.h    |  10 +-
 drivers/staging/lustre/include/linux/lnet/api.h    |  40 +-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  69 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  | 234 +++----
 .../staging/lustre/include/linux/lnet/socklnd.h    |  20 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 107 +--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 642 +++++++++---------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 121 ++--
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  22 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    | 125 ++--
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    | 566 ++++++++--------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  56 +-
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |  20 +-
 .../lustre/lnet/klnds/socklnd/socklnd_modparams.c  |  54 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |  99 ++-
 drivers/staging/lustre/lnet/libcfs/debug.c         |  22 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |   8 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   4 +-
 .../lustre/lnet/libcfs/linux-crypto-adler.c        |   2 +-
 drivers/staging/lustre/lnet/libcfs/linux-crypto.c  |   1 -
 drivers/staging/lustre/lnet/libcfs/module.c        | 128 ++--
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   5 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |  12 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |  30 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 115 ++--
 drivers/staging/lustre/lnet/lnet/config.c          |  86 ++-
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |   2 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c          |   4 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 112 ++--
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |  72 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  36 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |  21 +-
 drivers/staging/lustre/lnet/lnet/module.c          |   3 +-
 drivers/staging/lustre/lnet/lnet/net_fault.c       |   1 -
 drivers/staging/lustre/lnet/lnet/nidstrings.c      | 126 ++--
 drivers/staging/lustre/lnet/lnet/peer.c            |  57 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  42 +-
 drivers/staging/lustre/lnet/lnet/router_proc.c     |  65 +-
 drivers/staging/lustre/lnet/selftest/brw_test.c    |  20 +-
 drivers/staging/lustre/lnet/selftest/console.h     |   2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |  22 +-
 drivers/staging/lustre/lnet/selftest/rpc.h         | 132 ++--
 drivers/staging/lustre/lustre/fid/fid_lib.c        |   2 +-
 drivers/staging/lustre/lustre/fid/fid_request.c    |  12 +-
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |   4 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c      |  18 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h   |  36 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |  14 +-
 drivers/staging/lustre/lustre/include/cl_object.h  | 340 +++++-----
 .../staging/lustre/lustre/include/lprocfs_status.h |  95 +--
 drivers/staging/lustre/lustre/include/lu_object.h  | 354 +++++-----
 .../staging/lustre/lustre/include/lustre_debug.h   |   4 +-
 .../staging/lustre/lustre/include/lustre_disk.h    |  48 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 298 ++++-----
 .../lustre/lustre/include/lustre_dlm_flags.h       | 326 ++++-----
 .../staging/lustre/lustre/include/lustre_export.h  |  82 +--
 drivers/staging/lustre/lustre/include/lustre_fid.h |  44 +-
 drivers/staging/lustre/lustre/include/lustre_fld.h |  18 +-
 drivers/staging/lustre/lustre/include/lustre_ha.h  |   2 +-
 .../staging/lustre/lustre/include/lustre_handles.h |   6 +-
 .../staging/lustre/lustre/include/lustre_import.h  | 225 +++----
 .../staging/lustre/lustre/include/lustre_intent.h  |  24 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h |   2 -
 drivers/staging/lustre/lustre/include/lustre_lmv.h |  26 +-
 drivers/staging/lustre/lustre/include/lustre_log.h |  44 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   4 +-
 drivers/staging/lustre/lustre/include/lustre_mds.h |   4 +-
 drivers/staging/lustre/lustre/include/lustre_net.h | 502 +++++++-------
 .../lustre/lustre/include/lustre_nrs_fifo.h        |   6 +-
 .../lustre/lustre/include/lustre_req_layout.h      |  10 +-
 drivers/staging/lustre/lustre/include/lustre_sec.h | 338 +++++-----
 .../staging/lustre/lustre/include/lustre_swab.h    |   6 +-
 drivers/staging/lustre/lustre/include/obd.h        | 539 +++++++--------
 drivers/staging/lustre/lustre/include/obd_cksum.h  |   4 +-
 drivers/staging/lustre/lustre/include/obd_class.h  | 110 +--
 .../staging/lustre/lustre/include/obd_support.h    | 744 ++++++++++-----------
 drivers/staging/lustre/lustre/include/seq_range.h  |   2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |   8 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  12 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  22 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  50 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |  28 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  27 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  60 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  90 +--
 drivers/staging/lustre/lustre/llite/dir.c          | 132 ++--
 drivers/staging/lustre/lustre/llite/file.c         | 220 +++---
 drivers/staging/lustre/lustre/llite/glimpse.c      |  18 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  24 +-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |   4 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  74 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  64 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  54 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  54 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  82 +--
 drivers/staging/lustre/lustre/llite/namei.c        |  65 +-
 drivers/staging/lustre/lustre/llite/range_lock.c   |   4 +-
 drivers/staging/lustre/lustre/llite/range_lock.h   |  10 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  12 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  57 +-
 drivers/staging/lustre/lustre/llite/statahead.c    | 149 +++--
 drivers/staging/lustre/lustre/llite/super25.c      |  16 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      | 104 +--
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  58 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       | 181 +++--
 drivers/staging/lustre/lustre/llite/vvp_object.c   |  30 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  88 +--
 drivers/staging/lustre/lustre/llite/xattr.c        |  48 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |   6 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  46 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 382 +++++------
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c      |  24 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  50 +-
 drivers/staging/lustre/lustre/lov/lov_dev.c        |  72 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  76 +--
 drivers/staging/lustre/lustre/lov/lov_io.c         | 136 ++--
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  34 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c      |   8 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  63 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     | 154 ++---
 drivers/staging/lustre/lustre/lov/lov_offset.c     |   6 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |   6 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |  18 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  24 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |  16 +-
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |  32 +-
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |   4 +-
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |  29 +-
 drivers/staging/lustre/lustre/lov/lovsub_page.c    |   2 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c      |  18 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |  24 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        | 146 ++--
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  96 +--
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   8 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 266 ++++----
 drivers/staging/lustre/lustre/mgc/mgc_request.c    | 101 +--
 .../staging/lustre/lustre/obdclass/cl_internal.h   |   2 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  30 +-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |   4 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  42 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  62 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  20 +-
 drivers/staging/lustre/lustre/obdclass/debug.c     |  16 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  26 +-
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |   8 +-
 drivers/staging/lustre/lustre/obdclass/linkea.c    |   6 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |  40 +-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |   6 +-
 .../staging/lustre/lustre/obdclass/llog_internal.h |  24 +-
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |  18 +-
 .../lustre/lustre/obdclass/lprocfs_counters.c      |  18 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        | 184 ++---
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 120 ++--
 .../lustre/lustre/obdclass/lustre_handles.c        |   6 +-
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |  12 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  39 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  23 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    | 284 ++++----
 .../staging/lustre/lustre/obdecho/echo_internal.h  |   4 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   8 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  71 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   6 +-
 drivers/staging/lustre/lustre/osc/osc_dev.c        |  42 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   6 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  42 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  42 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |  30 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |   8 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  48 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  77 +--
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  10 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  14 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |  21 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |   2 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    | 304 ++++-----
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  11 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |   1 -
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 112 ++--
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  18 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |  22 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |   3 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |  22 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  80 +--
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |  22 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c    |  40 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |  94 +--
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  36 +-
 192 files changed, 6805 insertions(+), 6827 deletions(-)

-- 
1.8.3.1
