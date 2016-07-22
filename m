From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:43:53 -0400
Subject: [lustre-devel] [PATCH 00/58] staging: lustre: bug fixes from lustre
	2.5.[56-58]
Message-ID: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Here is the next batch of fixes and cleanups that went into
Lustre from versions 2.5.56 up to 2.5.58. Besides those changes
the patches for LU-3531/LU-4906 were broken into several smaller
patches as required for the staging tree. The rest of the patches
here are minor fixes and some removal of dead or obsolete code.

Chris Horn (1):
  staging: lustre: ptlrpc: Early replies need to honor at_max

Dmitry Eremin (1):
  staging: lustre: lmv: fix issue found by Klocwork Insight tool

Fan Yong (4):
  staging: lustre: obdclass: bug fixes for lu_device_type handling
  staging: lustre: llite: enable clients to inject error for lfsck
  staging: lustre: obdclass: unified flow control interfaces
  staging: lustre: reorder LOV_MAGIC_* definition

Jian Yu (1):
  staging: lustre: obdclass: fix lmd_parse() to handle comma-separated
    NIDs

Jinshan Xiong (3):
  staging: lustre: osc: allow to call brw_commit() multiple times
  staging: lustre: llite: avoid a deadlock in page write
  staging: lustre: lov: handle the case of stripe size is not power 2

John L. Hammond (9):
  staging: lustre: mdc: fixup MDS_SWAP_LAYOUTS ELC handling
  staging: lustre: don't need to const __u64 parameters for
    lustre_idl.h
  staging: lustre: const correct FID/OSTID/... helpers
  staging: lustre: use bool for several function in
    lustre_idl.h/lustre_fid.h
  staging: lustre: simplify inline functions in lustre_fid.h
  staging: lustre: lmv: access lum_stripe_offset as little endian
  staging: lustre: lmv: cleanup req in lmv_getattr_name()
  staging: lustre: lmv: rename request to preq in lmv_getattr_name()
  staging: lustre: move ioctls to lustre_ioctl.h

Nathaniel Clark (1):
  staging: lustre: lmv: Ensure lmv_intent_lookup cleans up reqp

Ryan Haasken (1):
  staging: lustre: libcfs: Only dump log once per sec. to avoid EEXIST

Vitaly Fertman (1):
  staging: lustre: ldlm: flock completion fixes.

wang di (36):
  staging: lustre: obd: expand op_cli_flags
  staging: lustre: obd: rename struct lmv_stripe_md field mea to lmv
  staging: lustre: ptlrpc: remove wirecheck for struct lmv_stripe_md
  staging: lustre: llite: cache directory striping information
  staging: lustre: lmv: add new lmv structures
  staging: lustre: mdc: handle IT_READDIR operations
  staging: lustre: llite: label the debug info
  staging: lustre: llite: pass struct md_op_data to ll_dir_read
  staging: lustre: llite: remove debug message in ll_dir_read
  staging: lustre: llite: reduce indent in ll_dir_read
  staging: lustre: llite: set next only when needed in ll_dir_read
  staging: lustre: llite: handle done flags differently in ll_dir_read
  staging: lustre: llite: change done flag in ll_dir_read to bool
  staging: lustre: llite: rename some variables for ll_dir_read
  staging: lustre: llite: clarify some debug messages for statahead
  staging: lustre: llite: remove code never called
  staging: lustre: llite: pass in __u64 pos for ll_dir_read
  staging: lustre: llite: do post work for statahead in readdir case
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

 .../lustre/include/linux/libcfs/libcfs_fail.h      |    3 +
 drivers/staging/lustre/lnet/libcfs/debug.c         |    9 +-
 drivers/staging/lustre/lnet/libcfs/fail.c          |    6 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |   55 +--
 drivers/staging/lustre/lustre/include/cl_object.h  |    3 +
 drivers/staging/lustre/lustre/include/lu_object.h  |    3 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |  250 ++++++--
 .../lustre/lustre/include/lustre/lustre_ioctl.h    |  412 ++++++++++++
 .../lustre/lustre/include/lustre/lustre_user.h     |   39 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   11 +-
 .../lustre/lustre/include/lustre_dlm_flags.h       |   36 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |   30 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h |  286 +---------
 drivers/staging/lustre/lustre/include/lustre_lmv.h |  130 ++++
 drivers/staging/lustre/lustre/include/lustre_mdc.h |    9 +-
 drivers/staging/lustre/lustre/include/obd.h        |   60 +--
 drivers/staging/lustre/lustre/include/obd_class.h  |   24 +
 .../staging/lustre/lustre/include/obd_support.h    |    5 +
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   98 +++-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   23 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   16 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    8 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  471 +++++++++-----
 drivers/staging/lustre/lustre/llite/file.c         |  178 +++++-
 .../staging/lustre/lustre/llite/llite_internal.h   |   49 ++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  258 ++++++++-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |   19 +-
 drivers/staging/lustre/lustre/llite/namei.c        |  104 +++-
 drivers/staging/lustre/lustre/llite/rw.c           |    4 +
 drivers/staging/lustre/lustre/llite/rw26.c         |    5 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   77 ++-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    6 -
 drivers/staging/lustre/lustre/llite/vvp_req.c      |    2 +
 drivers/staging/lustre/lustre/llite/xattr.c        |    7 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  287 ++++++++--
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   67 ++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  656 ++++++++++++++++----
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    1 +
 drivers/staging/lustre/lustre/lov/lov_object.c     |    1 +
 drivers/staging/lustre/lustre/lov/lov_page.c       |   11 +-
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |   17 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    2 -
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   66 +--
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   21 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   22 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    8 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  132 ++++
 .../lustre/lustre/obdclass/linux/linux-module.c    |    1 +
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   34 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |    1 +
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   21 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    1 +
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   19 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    9 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    8 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   11 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   37 ++
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   18 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   33 +-
 60 files changed, 2942 insertions(+), 1242 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_lmv.h
