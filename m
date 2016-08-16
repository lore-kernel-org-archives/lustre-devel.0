From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:13 -0400
Subject: [lustre-devel] [PATCH 00/80] staging: lustre: majority of missing
	fixes for 2.6 release
Message-ID: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This is the combination of two previous patch sets that cover missing
fixes for lustre version 2.5.56 to the 2.6 release minus a few patches that
have some bug regressions. Also in this update are the latest LNet fixes.

Alexander Boyko (1):
  staging: lustre: lnet: make connection more stable with packet loss

Andriy Skulysh (1):
  staging: lustre: ptlrpc: request gets stuck in UNREGISTERING phase

Brian Behlendorf (1):
  staging: lustre: obd: limit lu_object cache

Chris Horn (1):
  staging: lustre: ptlrpc: Early replies need to honor at_max

Christopher J. Morrone (1):
  staging: lustre: Remove static declaration in anonymous union

Dmitry Eremin (2):
  staging: lustre: lmv: fix issue found by Klocwork Insight tool
  staging: lustre: lmv: build error with gcc 4.7.0 20110509

Doug Oucharek (3):
  staging: lustre: lnet: Do not drop message when shutting down LNet
  staging: lustre: lnet: Correct position of lnet_ni_decref()
  staging: lustre: lnet: Stop Infinite CON RACE Condition

Emoly Liu (1):
  staging: lustre: ldlm: improve ldlm_lock_create() return value

Fan Yong (6):
  staging: lustre: obdclass: bug fixes for lu_device_type handling
  staging: lustre: llite: enable clients to inject error for lfsck
  staging: lustre: obdclass: unified flow control interfaces
  staging: lustre: reorder LOV_MAGIC_* definition
  staging: lustre: lov: new pattern flag for partially repaired file
  staging: lustre: lmv: build master LMV EA dynamically build via readdir

Gregoire Pichon (1):
  staging: lustre: llite: fix inconsistencies of root squash feature

Hongchao Zhang (2):
  staging: lustre: llite: set dir LOV xattr length variable
  staging: lustre: osc: Automatically increase the max_dirty_mb

James Simmons (3):
  staging: lustre: obdclass: compile issues with variable not being initialized
  staging: lustre: include: fix one off errors in lustre_id.h
  staging: lustre: llite: remove assert for acl refcount

Jian Yu (1):
  staging: lustre: obdclass: fix lmd_parse() to handle comma-separated NIDs

Jinshan Xiong (7):
  staging: lustre: osc: allow to call brw_commit() multiple times
  staging: lustre: llite: avoid a deadlock in page write
  staging: lustre: lov: handle the case of stripe size is not power 2
  staging: lustre: llite: Fix the deadlock in balance_dirty_pages()
  staging: lustre: llite: Change readdir BRW metrics
  staging: lustre: clio: Reduce memory overhead of per-page allocation
  staging: lustre: osc: revise unstable pages accounting

John L. Hammond (13):
  staging: lustre: mdc: fixup MDS_SWAP_LAYOUTS ELC handling
  staging: lustre: don't need to const __u64 parameters for lustre_idl.h
  staging: lustre: const correct FID/OSTID/... helpers
  staging: lustre: use bool for several function in lustre_idl.h/lustre_fid.h
  staging: lustre: simplify inline functions in lustre_fid.h
  staging: lustre: lmv: access lum_stripe_offset as little endian
  staging: lustre: lmv: cleanup req in lmv_getattr_name()
  staging: lustre: lmv: rename request to preq in lmv_getattr_name()
  staging: lustre: move ioctls to lustre_ioctl.h
  staging: lustre: llite: validate names
  staging: lustre: uapi: reduce scope of lustre_idl.h
  staging: lustre: mdt: add mbo_ prefix to members of struct mdt_body
  staging: lustre: obd: validate open handle cookies

Lai Siyao (2):
  staging: lustre: fid: do open-by-fid by default
  staging: lustre: ptlrpc: add OBD_CONNECT_UNLINK_CLOSE flag

Liang Zhen (1):
  staging: lustre: lnet: lock improvement for ko2iblnd

Mikhail Pershin (1):
  staging: lustre: llog: keep llog ctxt indices constant

Nathaniel Clark (1):
  staging: lustre: lmv: Ensure lmv_intent_lookup cleans up reqp

Niu Yawei (1):
  staging: lustre: obd: rename lsr_padding to lsr_valid

Patrick Farrell (1):
  staging: lustre: fld: add fld description documentation

Ryan Haasken (1):
  staging: lustre: libcfs: Only dump log once per sec. to avoid EEXIST

Vitaly Fertman (1):
  staging: lustre: ldlm: flock completion fixes.

wang di (27):
  staging: lustre: llite: add md_op_data parameter to ll_get_dir_page
  staging: lustre: llite: remove comment from ll_dir_read
  staging: lustre: llite: style cleanup for llite_internal.h
  staging: lustre: llite: pass inode to ll_release_page
  staging: lustre: llite: change remove parameter to bool
  staging: lustre: mdc: don't take rpc lock for readdir case
  staging: lustre: lmv: remove unused lmv_get_mea function
  staging: lustre: lmv: remove duplicate MAX_HASH_*
  staging: lustre: lmv: change handling of lmv striping information
  staging: lustre: lmv: remove lmv_get_easize
  staging: lustre: lmv: replace obd_free_memmd with lmv_free_memmd
  staging: lustre: create striped directory
  staging: lustre: llite: fix "getdirstripe" to show stripe info
  staging: lustre: delete striped directory
  staging: lustre: add ability to migrate inodes.
  staging: lustre: llite: a few fixes for migration.
  staging: lustre: lmv: lookup remote migrating object in LMV
  staging: lustre: llite: add error handler in inode prepare phase
  staging: lustre: lmv: separate master object with master stripe
  staging: lustre: llite: a few fixes about readdir of striped dir.
  staging: lustre: lmv: validate lock with correct stripe FID
  staging: lustre: lmv: Match MDT where the FID locates first
  staging: lustre: llite: use the correct mode for striped directory
  staging: lustre: mdc: always use D_INFO for debug info when mdc_put_rpc_lock fails
  staging: lustre: lmv: try all stripes for unknown hash functions
  staging: lustre: obd: implement md_read_page
  staging: lustre: llite: set op_max_pages

 .../lustre/include/linux/libcfs/libcfs_fail.h      |    3 +
 .../lustre/include/linux/libcfs/libcfs_private.h   |    9 -
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    2 +
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   78 +-
 drivers/staging/lustre/lnet/libcfs/debug.c         |    9 +-
 drivers/staging/lustre/lnet/libcfs/fail.c          |    6 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |    2 -
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    3 +
 drivers/staging/lustre/lustre/fld/fld_internal.h   |   19 +
 drivers/staging/lustre/lustre/fld/fld_request.c    |   55 +--
 drivers/staging/lustre/lustre/include/cl_object.h  |   75 +-
 .../staging/lustre/lustre/include/lprocfs_status.h |    6 +
 drivers/staging/lustre/lustre/include/lu_object.h  |   19 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |  341 +++++----
 .../lustre/lustre/include/lustre/lustre_ioctl.h    |  412 ++++++++++
 .../lustre/lustre/include/lustre/lustre_user.h     |   73 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   11 +-
 .../lustre/lustre/include/lustre_dlm_flags.h       |   36 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |   30 +-
 .../staging/lustre/lustre/include/lustre_handles.h |    3 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h |  286 +-------
 .../staging/lustre/lustre/include/lustre_lite.h    |    1 -
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   67 ++-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   23 +-
 drivers/staging/lustre/lustre/include/lustre_mds.h |    3 -
 drivers/staging/lustre/lustre/include/lustre_ver.h |   13 +-
 drivers/staging/lustre/lustre/include/obd.h        |  123 ++--
 drivers/staging/lustre/lustre/include/obd_class.h  |   66 ++-
 .../staging/lustre/lustre/include/obd_support.h    |    9 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  102 ++-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   16 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   53 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   29 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   33 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  382 ++++++---
 drivers/staging/lustre/lustre/llite/file.c         |  311 ++++++--
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   57 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  434 ++++++++--
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |   57 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  109 +++-
 drivers/staging/lustre/lustre/llite/namei.c        |  162 +++--
 drivers/staging/lustre/lustre/llite/rw.c           |    4 +
 drivers/staging/lustre/lustre/llite/rw26.c         |    7 +
 drivers/staging/lustre/lustre/llite/statahead.c    |   46 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |    6 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    6 -
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    6 +-
 drivers/staging/lustre/lustre/llite/vvp_req.c      |    2 +
 drivers/staging/lustre/lustre/llite/xattr.c        |   29 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |   12 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  339 +++++++--
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |  127 ++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  865 ++++++++++++++++----
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |    4 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |   22 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    1 +
 drivers/staging/lustre/lustre/lov/lov_object.c     |    1 +
 drivers/staging/lustre/lustre/lov/lov_page.c       |   12 +-
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |   17 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    7 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  200 ++---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   69 +-
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   12 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   73 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   10 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   12 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   10 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  134 +++-
 .../lustre/lustre/obdclass/linux/linux-module.c    |    1 +
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |    1 +
 .../lustre/lustre/obdclass/lprocfs_status.c        |  144 ++++
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  125 ++-
 .../lustre/lustre/obdclass/lustre_handles.c        |    4 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |    1 +
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   23 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    1 +
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   10 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  135 +---
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    3 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |    7 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  208 ++++-
 drivers/staging/lustre/lustre/osc/osc_request.c    |   64 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   12 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   12 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   93 ++-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   18 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  346 +++++----
 88 files changed, 4588 insertions(+), 2183 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
