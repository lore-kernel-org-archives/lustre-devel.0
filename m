From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 21:59:43 -0500
Subject: [lustre-devel] [PATCH v2 00/84] Lustre cleanups
Message-ID: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Due to unfortunate reordering that broke the build in the middle,
I am resending the previous patchset with some extra added patches.

This contains various Lustre cleanups and coding style fixes,
also hunts out various ifdefs that we don't really need
and remove various unused code and other fixes I seem to
be noticing along the way while looking at all the checkpatch warnings.

Oleg Drokin (84):
  staging/lustre/ldlm: Remove unused lr_most_restr from struct
    ldlm_resource
  staging/lustre/fld: Remove useless typedefs
  staging/lustre: Get rid of client_obd_lock_t typedef
  staging/lustre: Get rid of loc_flags_t typedef
  staging/lustre: Get rid of cksum_type_t typedef
  staging/lustre: Get rid of ost_cmd_t typedef
  staging/lustre: Get rid of quota_cmd_t typedef
  staging/lustre: Get rid of mds_cmd_t typedef
  staging/lustre: Get rid of mds_reint_t, mdt_reint_t typedefs
  staging/lustre: Get rid of ldlm_cmd_t typedef
  staging/lustre: Remove ldlm type/mode typedefs
  staging/lustre: Get rid of mgs_cmd_t typedef
  staging/lustre: Get rid of obd_cmd_t typedef
  staging/lustre: Get rid of llog_op_type typedef
  staging/lustre: Get rid of sec_cmd_t typedef
  staging/lustre: Get rid of object update code
  staging/lustre: Get rid of lustre_fid typedef
  staging/lustre: Get rid of lustre_quota_version typedef
  staging/lustre: Get rid of ldlm_error_t typedef
  staging/lustre: Remove ldlm_appetite_t typedef
  staging/lustre: Get rid of ldlm_ns_type_t typedef
  staging/lustre: Get rid of ldlm_cancel_flags_t typedef
  staging/lustre/llite: Get rid of se_stat_t typedef
  staging/lustre: Remove lustre_build_version.h
  staging/lustre: Get rid of C99 comments in lustre_idl.h
  staging/lustre: Remove server-side changelog defines
  staging/lustre: Remove FSF mailing address from GPL notices
  staging/lustre: Remove server-only values from enum lu_dirent_attrs
  staging/lustre: Remove *_CONNECT_SUPPORTED defines
  staging/lustre: Remove duplicated quota defines
  staging/lustre: Remove unused struct quota_body
  staging/lustre: Remove lquota_glb_rec, lquota_slv_rec and
    lquota_acct_rec
  staging/lustre: S_DIRSYNC is always defined in kernel
  staging/lustre: FMODE_READ and FMODE_WRITE are always defined in the
    kernel
  staging/lustre: Remove index file transfer structures
  staging/lustre: Remove server data from struct obd_export
  staging/lustre: Remove last_rcvd-file related data
  staging/lustre: Remove dead code in ldlm_lock_destroy_internal
  staging/lustre: MAY_NOT_BLOCK is always defined, don't check for it.
  staging/lustre: Remove unused lli_open_count from struct ll_inode_info
  staging/lustre: Reformat comments and structures in lustre_idl.h
  staging/lustre/include: Adjust comment style
  staging/lustre/fld: Adjust comments to better conform to coding style
  staging/lustre/fid: Adjust comments to better conform to coding style
  staging/lustre/lclient: Adjust comments to better conform to coding
    style
  staging/lustre/ldlm: Adjust comments to better conform to coding style
  staging/lustre/llite: Adjust comments to better conform to coding
    style
  staging/lustre/lmv: Adjust comments to better conform to coding style
  staging/lustre/lov: Adjust comments to better conform to coding style
  staging/lustre/mdc: Adjust comments to better conform to coding style
  staging/lustre/mgc: Adjust comments to better conform to coding style
  staging/lustre/obdclass: Adjust comments to better conform to coding
    style
  staging/lustre/obdecho: Adjust comments to better conform to coding
    style
  staging/lustre/osc: Adjust comments to better conform to coding style
  staging/lustre/ptlrpc: Adjust comments to better conform to coding
    style
  staging/lustre: Fix indentation mistakes
  staging/lustre: Remove stray space before newline in messages
  staging/lustre: Remove commented out obd functions
  staging/lustre: Remove unused members of struct ll_sb_info
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

 .../lustre/include/linux/libcfs/libcfs_cpu.h       |   5 -
 .../lustre/include/linux/libcfs/linux/linux-cpu.h  |   5 -
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |   5 -
 drivers/staging/lustre/lustre/fid/fid_request.c    |   6 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c      |  23 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h   |  33 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |  26 +-
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |   3 +-
 drivers/staging/lustre/lustre/include/cl_object.h  | 483 +++++++-------
 drivers/staging/lustre/lustre/include/lclient.h    |   3 +-
 drivers/staging/lustre/lustre/include/linux/obd.h  |  12 +-
 .../staging/lustre/lustre/include/lprocfs_status.h |  47 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |  12 +-
 .../lustre/lustre/include/lustre/ll_fiemap.h       |  63 +-
 .../lustre/include/lustre/lustre_build_version.h   |   2 -
 .../lustre/lustre/include/lustre/lustre_idl.h      | 741 ++++++---------------
 .../lustre/lustre/include/lustre/lustre_user.h     |  98 ++-
 drivers/staging/lustre/lustre/include/lustre_cfg.h |  11 +-
 .../staging/lustre/lustre/include/lustre_disk.h    | 252 +------
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 115 ++--
 .../lustre/lustre/include/lustre_dlm_flags.h       |  51 +-
 .../staging/lustre/lustre/include/lustre_export.h  |  73 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |  20 +-
 drivers/staging/lustre/lustre/include/lustre_fld.h |  33 +-
 .../staging/lustre/lustre/include/lustre_handles.h |   3 +-
 .../staging/lustre/lustre/include/lustre_import.h  |   3 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h |   3 +-
 .../staging/lustre/lustre/include/lustre_lite.h    |  50 +-
 drivers/staging/lustre/lustre/include/lustre_log.h |   3 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   6 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |  61 +-
 .../lustre/lustre/include/lustre_req_layout.h      |  13 +-
 drivers/staging/lustre/lustre/include/lustre_sec.h | 128 ++--
 drivers/staging/lustre/lustre/include/obd.h        |  84 ++-
 drivers/staging/lustre/lustre/include/obd_cksum.h  |  21 +-
 drivers/staging/lustre/lustre/include/obd_class.h  | 131 ++--
 .../staging/lustre/lustre/include/obd_support.h    |  18 +-
 drivers/staging/lustre/lustre/lclient/glimpse.c    |   3 +-
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c |  24 +-
 .../staging/lustre/lustre/lclient/lcommon_misc.c   |   6 +-
 drivers/staging/lustre/lustre/ldlm/interval_tree.c |   6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |  14 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  51 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  15 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  35 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 110 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |  46 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 159 +++--
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  46 +-
 drivers/staging/lustre/lustre/llite/dcache.c       |  21 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  37 +-
 drivers/staging/lustre/lustre/llite/file.c         | 260 +++++---
 drivers/staging/lustre/lustre/llite/llite_close.c  |  23 +-
 .../staging/lustre/lustre/llite/llite_internal.h   | 136 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 125 ++--
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  26 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  24 +-
 drivers/staging/lustre/lustre/llite/llite_rmtacl.c |   8 +-
 drivers/staging/lustre/lustre/llite/lloop.c        |   2 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  19 +-
 drivers/staging/lustre/lustre/llite/namei.c        |  49 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  88 ++-
 drivers/staging/lustre/lustre/llite/rw26.c         |  65 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |  64 +-
 drivers/staging/lustre/lustre/llite/super25.c      |  10 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |   5 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  13 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  56 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   3 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  21 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |  23 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  27 +-
 drivers/staging/lustre/lustre/lmv/lmv_fld.c        |   3 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  11 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   4 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 129 ++--
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  87 ++-
 drivers/staging/lustre/lustre/lov/lov_ea.c         |   5 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  12 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |   2 +-
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  39 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        | 121 ++--
 drivers/staging/lustre/lustre/lov/lov_object.c     |  64 +-
 drivers/staging/lustre/lustre/lov/lov_offset.c     |  15 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  21 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |   3 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  20 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |  18 +-
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |   8 +-
 drivers/staging/lustre/lustre/lov/lovsub_page.c    |   2 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c      |  16 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |  16 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   3 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      | 129 ++--
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |  16 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  39 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  99 +--
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  78 ++-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |  47 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  11 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  10 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  19 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  68 +-
 .../lustre/lustre/obdclass/linux/linux-module.c    |   4 +-
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |   8 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |   6 +-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |   4 +-
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |   3 +-
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |   3 +-
 .../lustre/lustre/obdclass/lprocfs_counters.c      |   6 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        | 127 ++--
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   6 +-
 .../lustre/lustre/obdclass/lustre_handles.c        |   3 +-
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |   5 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  50 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  75 ++-
 drivers/staging/lustre/lustre/obdclass/obdo.c      |   6 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |  31 +-
 .../staging/lustre/lustre/obdecho/echo_internal.h  |   5 -
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |  24 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 186 ++++--
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  37 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   8 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  11 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  75 ++-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  79 ++-
 drivers/staging/lustre/lustre/osc/osc_quota.c      |  21 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 192 ++++--
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  40 +-
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |   3 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  51 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      | 163 ++---
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 117 +---
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |   8 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  25 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  46 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |  25 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |   2 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  79 +--
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |  16 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |   2 -
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |  18 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |  24 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |  33 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |  10 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c    |   3 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 200 +++---
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 272 --------
 150 files changed, 3534 insertions(+), 3967 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/lustre/lustre_build_version.h

-- 
2.1.0
