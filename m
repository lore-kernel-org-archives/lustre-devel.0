From: Joe Perches <joe@perches.com>
Date: Mon, 15 Aug 2016 12:33:22 -0700
Subject: [lustre-devel] [PATCH 0/2] staging: lustre: #include neatening
Message-ID: <cover.1471289489.git.joe@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Make it a bit easier to grep and help a future move out of staging.

Joe Perches (2):
  staging: lustre: Add include path to Makefile
  staging: lustre: Remove .. paths from '#include "' uses

 drivers/staging/lustre/Makefile                             |  3 +++
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h         |  6 +++---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h         |  8 ++++----
 drivers/staging/lustre/lnet/libcfs/debug.c                  |  2 +-
 drivers/staging/lustre/lnet/libcfs/fail.c                   |  2 +-
 drivers/staging/lustre/lnet/libcfs/hash.c                   |  2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c             |  2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c            |  2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c             |  2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c          |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c        |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c     |  4 ++--
 drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c    |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c      |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c        |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c     |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c       |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c  |  2 +-
 drivers/staging/lustre/lnet/libcfs/module.c                 | 10 +++++-----
 drivers/staging/lustre/lnet/libcfs/prng.c                   |  2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c              |  2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.h              |  2 +-
 drivers/staging/lustre/lnet/libcfs/workitem.c               |  2 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c                 |  2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c                   |  4 ++--
 drivers/staging/lustre/lnet/lnet/config.c                   |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-eq.c                   |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c                   |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c                   |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c                 |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c                  |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c                  |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c               |  4 ++--
 drivers/staging/lustre/lnet/lnet/lo.c                       |  2 +-
 drivers/staging/lustre/lnet/lnet/module.c                   |  4 ++--
 drivers/staging/lustre/lnet/lnet/net_fault.c                |  4 ++--
 drivers/staging/lustre/lnet/lnet/nidstrings.c               |  4 ++--
 drivers/staging/lustre/lnet/lnet/peer.c                     |  4 ++--
 drivers/staging/lustre/lnet/lnet/router.c                   |  2 +-
 drivers/staging/lustre/lnet/lnet/router_proc.c              |  4 ++--
 drivers/staging/lustre/lnet/selftest/conctl.c               |  6 +++---
 drivers/staging/lustre/lnet/selftest/conrpc.c               |  4 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.h               |  8 ++++----
 drivers/staging/lustre/lnet/selftest/console.c              |  4 ++--
 drivers/staging/lustre/lnet/selftest/console.h              |  8 ++++----
 drivers/staging/lustre/lnet/selftest/rpc.h                  |  2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h             | 10 +++++-----
 drivers/staging/lustre/lustre/fid/fid_internal.h            |  2 +-
 drivers/staging/lustre/lustre/fid/fid_lib.c                 |  2 +-
 drivers/staging/lustre/lustre/fid/fid_request.c             |  2 +-
 drivers/staging/lustre/lustre/fid/lproc_fid.c               |  2 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c               |  2 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h            |  2 +-
 drivers/staging/lustre/lustre/fld/fld_request.c             |  2 +-
 drivers/staging/lustre/lustre/fld/lproc_fld.c               |  2 +-
 drivers/staging/lustre/lustre/include/interval_tree.h       |  2 +-
 drivers/staging/lustre/lustre/include/linux/lustre_lite.h   |  2 +-
 drivers/staging/lustre/lustre/include/lu_object.h           |  2 +-
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h   |  4 ++--
 drivers/staging/lustre/lustre/include/lustre_disk.h         |  4 ++--
 drivers/staging/lustre/lustre/include/lustre_fid.h          |  2 +-
 drivers/staging/lustre/lustre/include/lustre_fld.h          |  2 +-
 drivers/staging/lustre/lustre/include/lustre_handles.h      |  2 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h          |  2 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h          |  2 +-
 drivers/staging/lustre/lustre/include/lustre_mds.h          |  2 +-
 drivers/staging/lustre/lustre/include/lustre_net.h          |  6 +++---
 drivers/staging/lustre/lustre/include/obd_cksum.h           |  4 ++--
 drivers/staging/lustre/lustre/include/obd_support.h         |  2 +-
 drivers/staging/lustre/lustre/ldlm/l_lock.c                 |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c            |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c               |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c              |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c             |  2 +-
 drivers/staging/lustre/lustre/llite/glimpse.c               |  2 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c            |  2 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c            |  2 +-
 drivers/staging/lustre/lustre/llite/rw.c                    |  2 +-
 drivers/staging/lustre/lustre/llite/rw26.c                  |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c            |  2 +-
 drivers/staging/lustre/lustre/lov/lov_cl_internal.h         |  2 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c                  |  2 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c               |  2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c                 |  2 +-
 drivers/staging/lustre/lustre/lov/lov_offset.c              |  2 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c                |  2 +-
 drivers/staging/lustre/lustre/lov/lov_request.c             |  2 +-
 drivers/staging/lustre/lustre/mgc/mgc_internal.h            |  2 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c          |  4 ++--
 drivers/staging/lustre/lustre/obdclass/cl_page.c            |  2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c          |  2 +-
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c |  4 ++--
 drivers/staging/lustre/lustre/obdclass/lu_object.c          |  4 ++--
 drivers/staging/lustre/lustre/obdclass/lu_ref.c             |  2 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c          |  2 +-
 drivers/staging/lustre/lustre/obdclass/uuid.c               |  2 +-
 drivers/staging/lustre/lustre/obdecho/echo_client.c         |  2 +-
 drivers/staging/lustre/lustre/osc/osc_cl_internal.h         |  2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c                |  2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c             |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/errno.c                |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c               |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c          |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c             |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c                  |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c             |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c         |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c              |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c              |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c                  |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c             |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c           |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c               |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c            |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c              |  2 +-
 115 files changed, 156 insertions(+), 153 deletions(-)

-- 
2.8.0.rc4.16.g56331f8
