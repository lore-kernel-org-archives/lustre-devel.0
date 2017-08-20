From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:25:54 -0400
Subject: [lustre-devel] [PATCH 00/64 v2] staging: lustre: uapi: normalize
	the lustre headers
Message-ID: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The headers for lustre/LNet for a long time lacked a clean separation in
its internal headers which resulted in kernel specific data structures
being exposed in user land code. This work unravels this mess and creates
a clear separation between lustre kernel space and lustre user land.
With this work done the include paths in the lustre kernel code can now
be normalized. This is the second version of the patch series which
includes a fix to include lustre_errno.h in the header lustre_net.h.
For some reason this only showed up on ia64 platforms but should be
resolved now. Second change was to add errno.h into lustre_ostid.h.
It is needed to handle the error codes returned for both user land
and kernel space.

Ben Evans (4):
  staging: lustre: uapi: Move functions out of lustre_idl.h
  staging: lustre: uapi: return error code for ostid_set_id
  staging: lustre: uapi: update URL doc link in lustre_fid.h
  staging: lustre: uapi: move lu_fid, ost_id funcs out of lustre_idl.h

James Simmons (60):
  staging: lustre: uapi: remove unused functions for lustre_fid.h
  staging: lustre: uapi: remove unused function in lustre_disk.h
  staging: lustre: uapi: remove userland version of obd_ioctl_*()
  staging: lustre: uapi: remove obd_ioctl_freedata() wrapper
  staging: lustre: uapi: remove obd_ioctl_popdata() wrapper
  staging: lustre: uapi: move obd_ioctl_getdata() declaration
  staging: lustre: uapi: move obd_ioctl_is_invalid() to linux-module.c
  staging: lustre: uapi: move lustre_ioctl.h to uapi directory
  staging: lustre: uapi: use __ALIGN_KERNEL for lustre_ioctl.h
  staging: lustre: uapi: cleanup headers for lustre_ioctl.h
  staging: lustre: uapi: label lustre_ioctl.h as a UAPI header
  staging: lustre: uapi: move kernel only prototypes out of lustre_param.h
  staging: lustre: uapi: remove included headers out of lustre_param.h
  staging: lustre: uapi: move lustre_param.h to uapi directory
  staging: lustre: uapi: label lustre_param.h as an uapi header
  staging: lustre: uapi: style cleanups for lustre_param.h
  staging: lustre: uapi: remove lustre_cfg_free wrapper
  staging: lustre: uapi: don't memory allocate in UAPI header
  staging: lustre: uapi: move lustre_cfg_string() to obd_config.c
  staging: lustre: obdclass: no need to check for kfree
  staging: lustre: uapi: move lustre_cfg.h to uapi directory
  staging: lustre: uapi: remove need for libcfs.h from lustre_cfg.h
  staging: lustre: uapi: change variable type to match
  staging: lustre: uapi: check if argument for lustre_cfg_buf() is NULL
  staging: lustre: uapi: style cleanup of lustre_cfg.h
  staging: lustre: uapi: label lustre_cfg.h as an uapi header
  staging: lustre: libcfs: remove htonl hack in libcfs.h
  staging: lustre: libcfs: remove LOGL and LOGU macros
  staging: lustre: libcfs: create libcfs_debug.h UAPI header
  staging: lustre: socklnd: create socklnd.h UAPI header
  staging: lustre: lnet: delete lnet.h
  staging: lustre: lnet: migrate headers to lnet uapi directory
  staging: lustre: libcfs: sort headers in libcfs.h
  staging: lustre: lnet: remove userland function prototype in lnetctl.h
  staging: lustre: lnet: remove BIT macro from lnetctl.h
  staging: lustre: uapi: remove libcfs.h from lustre_id.h/lustre_user.h
  staging: lustre: uapi: migrate remaining uapi headers to uapi directory
  staging: lustre: uapi: remove CONFIG_LUSTRE_OBD_MAX_IOCTL
  staging: lustre: uapi: use proper byteorder functions in lustre_idl.h
  staging: lustre: uapi: remove BIT macro from UAPI headers
  staging: lustre: fid: add include path to Makefile
  staging: lustre: fld: add include path to Makefile
  staging: lustre: ptlrpc: add include path to Makefile
  staging: lustre: llite: add include path to Makefile
  staging: lustre: lmv: add include path to Makefile
  staging: lustre: lov: add include path to Makefile
  staging: lustre: mdc: add include path to Makefile
  staging: lustre: mgc: add include path to Makefile
  staging: lustre: obdclass: add include path to Makefile
  staging: lustre: obdecho: add include path to Makefile
  staging: lustre: osc: add include path to Makefile
  staging: lustre: lustre: cleanup paths for lustre internal headers
  staging: lustre: lustre: cleanup paths for lustre UAPI headers
  staging: lustre: lnet: selftest: add include path to Makefile
  staging: lustre: lnet: add include path to Makefile
  staging: lustre: ko2iblnd: add include path to Makefile
  staging: lustre: ksocklnd: add include path to Makefile
  staging: lustre: libcfs: add include path to Makefile
  staging: lustre: libcfs: cleanup paths for libcfs headers
  staging: lustre: lnet: cleanup paths for all LNet headers

 .../staging/lustre/include/linux/libcfs/libcfs.h   |  28 +-
 .../lustre/include/linux/libcfs/libcfs_debug.h     | 104 +---
 .../lustre/include/linux/libcfs/libcfs_private.h   |  26 -
 drivers/staging/lustre/include/linux/lnet/api.h    |   2 +-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  12 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |   4 +-
 .../staging/lustre/include/linux/lnet/socklnd.h    |  12 +-
 .../lustre/include/uapi/linux/lnet/libcfs_debug.h  | 149 +++++
 .../libcfs => uapi/linux/lnet}/libcfs_ioctl.h      |   0
 .../lnet/lib-dlc.h => uapi/linux/lnet/lnet-dlc.h}  |   4 +-
 .../lnet/types.h => uapi/linux/lnet/lnet-types.h}  |   0
 .../lustre/include/{ => uapi}/linux/lnet/lnetctl.h |  51 +-
 .../lustre/include/{ => uapi}/linux/lnet/lnetst.h  |   0
 .../lustre/include/{ => uapi}/linux/lnet/nidstr.h  |   2 +-
 .../lnet/lnet.h => uapi/linux/lnet/socklnd.h}      |  24 +-
 .../uapi/linux/lustre}/lustre_cfg.h                | 188 +++---
 .../lustre/include/uapi/linux/lustre/lustre_fid.h  | 293 +++++++++
 .../uapi/linux/lustre/lustre_fiemap.h}             |   6 +-
 .../uapi/linux}/lustre/lustre_idl.h                | 682 +--------------------
 .../uapi/linux}/lustre/lustre_ioctl.h              | 203 +-----
 .../uapi/linux/lustre/lustre_kernelcomm.h}         |   6 +-
 .../include/uapi/linux/lustre/lustre_ostid.h       | 236 +++++++
 .../include/uapi/linux/lustre/lustre_param.h       |  94 +++
 .../uapi/linux}/lustre/lustre_user.h               |  15 +-
 .../uapi/linux/lustre}/lustre_ver.h                |   0
 drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile |   3 +
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   5 +-
 drivers/staging/lustre/lnet/klnds/socklnd/Makefile |   3 +
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   7 +-
 drivers/staging/lustre/lnet/libcfs/Makefile        |   3 +
 drivers/staging/lustre/lnet/libcfs/debug.c         |   2 +-
 drivers/staging/lustre/lnet/libcfs/fail.c          |   2 +-
 drivers/staging/lustre/lnet/libcfs/hash.c          |   2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |   2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |   2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c    |   2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   2 +-
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   2 +-
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   4 +-
 .../lustre/lnet/libcfs/linux/linux-curproc.c       |   2 +-
 .../staging/lustre/lnet/libcfs/linux/linux-debug.c |   2 +-
 .../staging/lustre/lnet/libcfs/linux/linux-mem.c   |   2 +-
 .../lustre/lnet/libcfs/linux/linux-module.c        |   2 +-
 .../staging/lustre/lnet/libcfs/linux/linux-prim.c  |   2 +-
 .../lustre/lnet/libcfs/linux/linux-tracefile.c     |   2 +-
 drivers/staging/lustre/lnet/libcfs/module.c        |   9 +-
 drivers/staging/lustre/lnet/libcfs/prng.c          |   2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |   2 +-
 drivers/staging/lustre/lnet/libcfs/workitem.c      |   2 +-
 drivers/staging/lustre/lnet/lnet/Makefile          |   3 +
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   4 +-
 drivers/staging/lustre/lnet/lnet/config.c          |   2 +-
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |   3 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   2 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c          |   2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   2 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   2 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |   2 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   4 +-
 drivers/staging/lustre/lnet/lnet/lo.c              |   3 +-
 drivers/staging/lustre/lnet/lnet/module.c          |   5 +-
 drivers/staging/lustre/lnet/lnet/net_fault.c       |   4 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |   4 +-
 drivers/staging/lustre/lnet/lnet/peer.c            |   4 +-
 drivers/staging/lustre/lnet/lnet/router.c          |   3 +-
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   5 +-
 drivers/staging/lustre/lnet/selftest/Makefile      |   3 +
 drivers/staging/lustre/lnet/selftest/conctl.c      |   6 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |   4 +-
 drivers/staging/lustre/lnet/selftest/conrpc.h      |   7 +-
 drivers/staging/lustre/lnet/selftest/console.c     |   4 +-
 drivers/staging/lustre/lnet/selftest/console.h     |   7 +-
 drivers/staging/lustre/lnet/selftest/rpc.h         |   2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |   9 +-
 drivers/staging/lustre/lustre/Kconfig              |  10 -
 drivers/staging/lustre/lustre/fid/Makefile         |   3 +
 drivers/staging/lustre/lustre/fid/fid_internal.h   |   4 +-
 drivers/staging/lustre/lustre/fid/fid_lib.c        |   5 +-
 drivers/staging/lustre/lustre/fid/fid_request.c    |  12 +-
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |  12 +-
 drivers/staging/lustre/lustre/fld/Makefile         |   3 +
 drivers/staging/lustre/lustre/fld/fld_cache.c      |  16 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h   |   8 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |  18 +-
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |  14 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |   4 +-
 drivers/staging/lustre/lustre/include/llog_swab.h  |   3 +-
 .../staging/lustre/lustre/include/lprocfs_status.h |   6 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |   6 +-
 .../staging/lustre/lustre/include/lustre_compat.h  |   2 +-
 .../staging/lustre/lustre/include/lustre_debug.h   |   4 +-
 .../staging/lustre/lustre/include/lustre_disk.h    |  23 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  25 +-
 .../lustre/include/{lustre => }/lustre_errno.h     |   0
 .../staging/lustre/lustre/include/lustre_export.h  |   6 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |  84 ++-
 drivers/staging/lustre/lustre/include/lustre_fld.h |   5 +-
 .../staging/lustre/lustre/include/lustre_handles.h |   2 +-
 .../staging/lustre/lustre/include/lustre_import.h  |   4 +-
 .../lustre/lustre/include/lustre_kernelcomm.h      |   2 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h |  12 +-
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   2 +-
 drivers/staging/lustre/lustre/include/lustre_log.h |   4 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |  15 +-
 drivers/staging/lustre/lustre/include/lustre_mds.h |  11 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |  29 +-
 drivers/staging/lustre/lustre/include/lustre_nrs.h |   2 +-
 .../staging/lustre/lustre/include/lustre_obdo.h    |   2 +-
 .../staging/lustre/lustre/include/lustre_param.h   | 109 ----
 .../staging/lustre/lustre/include/lustre_swab.h    |   8 +-
 drivers/staging/lustre/lustre/include/obd.h        |  18 +-
 drivers/staging/lustre/lustre/include/obd_cksum.h  |   6 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |  35 +-
 .../staging/lustre/lustre/include/obd_support.h    |   6 +-
 drivers/staging/lustre/lustre/include/seq_range.h  |   2 +-
 drivers/staging/lustre/lustre/ldlm/interval_tree.c |   6 +-
 drivers/staging/lustre/lustre/ldlm/l_lock.c        |   6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |  12 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   8 +-
 .../staging/lustre/lustre/ldlm/ldlm_inodebits.c    |   6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   6 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  12 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   8 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c    |   6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   8 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  34 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   6 +-
 drivers/staging/lustre/lustre/llite/Makefile       |   3 +
 drivers/staging/lustre/lustre/llite/dcache.c       |   6 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  22 +-
 drivers/staging/lustre/lustre/llite/file.c         |  10 +-
 drivers/staging/lustre/lustre/llite/glimpse.c      |  16 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  35 +-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |   8 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  20 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  21 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   4 +-
 drivers/staging/lustre/lustre/llite/namei.c        |   7 +-
 drivers/staging/lustre/lustre/llite/range_lock.c   |   2 +-
 drivers/staging/lustre/lustre/llite/range_lock.h   |   4 +-
 drivers/staging/lustre/lustre/llite/rw.c           |   2 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   4 +-
 drivers/staging/lustre/lustre/llite/super25.c      |   6 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |   2 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |   4 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   2 +-
 drivers/staging/lustre/lustre/llite/vvp_lock.c     |   2 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   4 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   5 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |   5 +-
 drivers/staging/lustre/lustre/lmv/Makefile         |   3 +
 drivers/staging/lustre/lustre/lmv/lmv_fld.c        |  15 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  17 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   6 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  19 +-
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c      |   4 +-
 drivers/staging/lustre/lustre/lov/Makefile         |   3 +
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |   6 +-
 drivers/staging/lustre/lustre/lov/lov_dev.c        |   2 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c         |   6 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |   4 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c      |   4 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  40 +-
 drivers/staging/lustre/lustre/lov/lov_offset.c     |   4 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  13 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |   4 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |   6 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c      |   4 +-
 drivers/staging/lustre/lustre/mdc/Makefile         |   3 +
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |   4 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   2 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  10 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  22 +-
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   4 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  25 +-
 drivers/staging/lustre/lustre/mgc/Makefile         |   3 +
 drivers/staging/lustre/lustre/mgc/lproc_mgc.c      |   4 +-
 drivers/staging/lustre/lustre/mgc/mgc_internal.h   |  11 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  23 +-
 drivers/staging/lustre/lustre/obdclass/Makefile    |   3 +
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   8 +-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |   8 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  14 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   8 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  35 +-
 drivers/staging/lustre/lustre/obdclass/debug.c     |   6 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |   6 +-
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |   4 +-
 drivers/staging/lustre/lustre/obdclass/linkea.c    |   6 +-
 .../lustre/lustre/obdclass/linux/linux-module.c    | 100 ++-
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |   6 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |   6 +-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |   2 +-
 .../staging/lustre/lustre/obdclass/llog_internal.h |   2 +-
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |   4 +-
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |   4 +-
 .../lustre/lustre/obdclass/lprocfs_counters.c      |   4 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |   6 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  20 +-
 drivers/staging/lustre/lustre/obdclass/lu_ref.c    |  10 +-
 .../lustre/lustre/obdclass/lustre_handles.c        |   6 +-
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |  14 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  74 ++-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  44 +-
 drivers/staging/lustre/lustre/obdclass/obdo.c      |   6 +-
 .../staging/lustre/lustre/obdclass/statfs_pack.c   |   8 +-
 drivers/staging/lustre/lustre/obdclass/uuid.c      |   6 +-
 drivers/staging/lustre/lustre/obdecho/Makefile     |   3 +
 .../staging/lustre/lustre/obdecho/echo_client.c    |  31 +-
 drivers/staging/lustre/lustre/osc/Makefile         |   3 +
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   6 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   6 +-
 drivers/staging/lustre/lustre/osc/osc_dev.c        |   2 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |   4 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |   9 +-
 drivers/staging/lustre/lustre/osc/osc_quota.c      |   2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  32 +-
 drivers/staging/lustre/lustre/ptlrpc/Makefile      |   3 +
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  12 +-
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/errno.c       |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |   8 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  16 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |  18 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |   8 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c    |   6 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  12 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  10 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |  10 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |   6 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  20 +-
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |  10 +-
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |   4 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_module.c   |   8 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |  18 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |  18 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |  16 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  20 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |  13 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |  10 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c   |  16 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c    |  10 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |  10 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  11 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   8 +-
 250 files changed, 2091 insertions(+), 2182 deletions(-)
 create mode 100644 drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h
 rename drivers/staging/lustre/include/{linux/libcfs => uapi/linux/lnet}/libcfs_ioctl.h (100%)
 rename drivers/staging/lustre/include/{linux/lnet/lib-dlc.h => uapi/linux/lnet/lnet-dlc.h} (97%)
 rename drivers/staging/lustre/include/{linux/lnet/types.h => uapi/linux/lnet/lnet-types.h} (100%)
 rename drivers/staging/lustre/include/{ => uapi}/linux/lnet/lnetctl.h (62%)
 rename drivers/staging/lustre/include/{ => uapi}/linux/lnet/lnetst.h (100%)
 rename drivers/staging/lustre/include/{ => uapi}/linux/lnet/nidstr.h (98%)
 rename drivers/staging/lustre/include/{linux/lnet/lnet.h => uapi/linux/lnet/socklnd.h} (70%)
 rename drivers/staging/lustre/{lustre/include => include/uapi/linux/lustre}/lustre_cfg.h (52%)
 create mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
 rename drivers/staging/lustre/{lustre/include/lustre/ll_fiemap.h => include/uapi/linux/lustre/lustre_fiemap.h} (96%)
 rename drivers/staging/lustre/{lustre/include => include/uapi/linux}/lustre/lustre_idl.h (83%)
 rename drivers/staging/lustre/{lustre/include => include/uapi/linux}/lustre/lustre_ioctl.h (63%)
 rename drivers/staging/lustre/{lustre/include/uapi_kernelcomm.h => include/uapi/linux/lustre/lustre_kernelcomm.h} (95%)
 create mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
 create mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h
 rename drivers/staging/lustre/{lustre/include => include/uapi/linux}/lustre/lustre_user.h (99%)
 rename drivers/staging/lustre/{lustre/include => include/uapi/linux/lustre}/lustre_ver.h (100%)
 rename drivers/staging/lustre/lustre/include/{lustre => }/lustre_errno.h (100%)
 delete mode 100644 drivers/staging/lustre/lustre/include/lustre_param.h

-----
Changelog)

1) Initial patch set submitted with lustre_errno.h build issues.

2) Include lustre_errno.h in the header lustre_net.h
   Add <linux/errno.h> to lustre_ostid.h header.

-- 
1.8.3.1
