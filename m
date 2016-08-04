From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:36 -0400
Subject: [lustre-devel] [PATCH 00/31] staging: lustre: next batch of pre-2.6
	patches
Message-ID: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This series covers most of the remaining fixes from the lustre 2.6
release. Only a few patches are not included due to bugs not yet
resolved. Also two fixes are included that cover bugs discovered
during the 4.7 release cycle.

Andriy Skulysh (1):
  staging: lustre: ptlrpc: request gets stuck in UNREGISTERING phase

Brian Behlendorf (1):
  staging: lustre: obd: limit lu_object cache

Christopher J. Morrone (1):
  staging: lustre: Remove static declaration in anonymous union

Emoly Liu (1):
  staging: lustre: ldlm: improve ldlm_lock_create() return value

Fan Yong (2):
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

Jinshan Xiong (4):
  staging: lustre: llite: Fix the deadlock in balance_dirty_pages()
  staging: lustre: llite: Change readdir BRW metrics
  staging: lustre: clio: Reduce memory overhead of per-page allocation
  staging: lustre: osc: revise unstable pages accounting

John L. Hammond (3):
  staging: lustre: llite: validate names
  staging: lustre: uapi: reduce scope of lustre_idl.h
  staging: lustre: mdt: add mbo_ prefix to members of struct mdt_body

Lai Siyao (2):
  staging: lustre: fid: do open-by-fid by default
  staging: lustre: ptlrpc: add OBD_CONNECT_UNLINK_CLOSE flag

Mikhail Pershin (1):
  staging: lustre: llog: keep llog ctxt indices constant

Niu Yawei (1):
  staging: lustre: obd: rename lsr_padding to lsr_valid

Patrick Farrell (1):
  staging: lustre: fld: add fld description documentation

wang di (7):
  staging: lustre: llite: a few fixes about readdir of striped dir.
  staging: lustre: lmv: separate master object with master stripe
  staging: lustre: lmv: validate lock with correct stripe FID
  staging: lustre: lmv: Match MDT where the FID locates first
  staging: lustre: llite: use the correct mode for striped directory
  staging: lustre: mdc: always use D_INFO for debug info when mdc_put_rpc_lock fails
  staging: lustre: lmv: try all stripes for unknown hash functions

 .../lustre/include/linux/libcfs/libcfs_private.h   |    9 -
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |    2 -
 drivers/staging/lustre/lustre/fld/fld_internal.h   |   19 ++
 drivers/staging/lustre/lustre/include/cl_object.h  |   72 ++---
 .../staging/lustre/lustre/include/lprocfs_status.h |    6 +
 drivers/staging/lustre/lustre/include/lu_object.h  |   16 +
 .../lustre/lustre/include/lustre/lustre_idl.h      |  208 +++++++------
 .../lustre/lustre/include/lustre/lustre_user.h     |   38 ++-
 .../staging/lustre/lustre/include/lustre_lite.h    |    1 -
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   53 ++--
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   14 +-
 drivers/staging/lustre/lustre/include/lustre_mds.h |    3 -
 drivers/staging/lustre/lustre/include/lustre_ver.h |   13 +-
 drivers/staging/lustre/lustre/include/obd.h        |   58 ++--
 drivers/staging/lustre/lustre/include/obd_class.h  |   27 ++-
 .../staging/lustre/lustre/include/obd_support.h    |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   12 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   28 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   13 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   25 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  130 +++++---
 drivers/staging/lustre/lustre/llite/file.c         |  135 +++++---
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   13 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  279 +++++++++-------
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |   49 ++-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  109 ++++++-
 drivers/staging/lustre/lustre/llite/namei.c        |   60 ++--
 drivers/staging/lustre/lustre/llite/rw26.c         |   12 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |    4 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |    6 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    6 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   22 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |   12 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  164 +++++-----
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   61 +++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  298 ++++++++++++-----
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |    4 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |   22 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |    1 +
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    5 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  134 +++++----
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   56 +---
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   12 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   60 ++--
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   10 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   12 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 -
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |    1 +
 .../lustre/lustre/obdclass/lprocfs_status.c        |  144 ++++++++
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   91 ++++--
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    2 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   10 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  124 +------
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    3 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |    7 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  208 ++++++++++--
 drivers/staging/lustre/lustre/osc/osc_request.c    |   55 ++--
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    1 +
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   56 ++--
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  342 ++++++++++++--------
 63 files changed, 2074 insertions(+), 1279 deletions(-)
