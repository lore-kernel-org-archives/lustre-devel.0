From: James Simmons <jsimmons@infradead.org>
Date: Wed, 14 Jun 2017 11:01:15 -0400
Subject: [lustre-devel] [PATCH 0/6] staging: lustre: lustre: assortment of
	checkpatch cleanups
Message-ID: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This patch series covers a good chunk of the checkpatch issues in the
current lustre client code.

James Simmons (6):
  staging: lustre: lustre: resolve "use spaces between elements" checkpatch errors
  staging: lustre: lustre: make all struct file_operations constant
  staging: lustre: lustre: fix all bare unsigned usage
  staging: lustre: lustre: add all missing indentifier names
  staging: lustre: lustre: several over 80 characters cleanups
  staging: lustre: lustre: fix all braces issues reported by checkpatch

 drivers/staging/lustre/lustre/fid/fid_request.c    |  2 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c      |  9 ++--
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |  2 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |  6 +--
 .../staging/lustre/lustre/include/lprocfs_status.h | 15 ++++---
 drivers/staging/lustre/lustre/include/lu_object.h  |  4 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |  6 +--
 .../lustre/lustre/include/lustre/lustre_user.h     |  2 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |  5 ++-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h | 40 +++++++++--------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 42 +++++++++++-------
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 20 +++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  4 +-
 drivers/staging/lustre/lustre/llite/dcache.c       |  4 +-
 drivers/staging/lustre/lustre/llite/dir.c          | 12 ++---
 drivers/staging/lustre/lustre/llite/file.c         | 51 +++++++++++-----------
 .../staging/lustre/lustre/llite/llite_internal.h   | 36 ++++++++-------
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 39 +++++++++--------
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  2 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    | 13 +++---
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 12 ++---
 drivers/staging/lustre/lustre/llite/namei.c        | 46 +++++++++----------
 drivers/staging/lustre/lustre/llite/rw.c           |  6 ++-
 drivers/staging/lustre/lustre/llite/rw26.c         |  4 +-
 drivers/staging/lustre/lustre/llite/statahead.c    | 23 +++++-----
 drivers/staging/lustre/lustre/llite/super25.c      |  3 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |  4 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      | 11 ++---
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |  2 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |  6 +--
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  4 +-
 drivers/staging/lustre/lustre/lmv/lmv_fld.c        |  2 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  9 ++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 50 +++++++++++----------
 drivers/staging/lustre/lustre/lov/lov_io.c         |  2 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c      |  4 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     |  7 ++-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  9 ++--
 drivers/staging/lustre/lustre/lov/lov_pool.c       | 19 +++++---
 drivers/staging/lustre/lustre/lov/lproc_lov.c      | 12 +++--
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        | 15 ++++---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      | 11 ++---
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 16 +++----
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  5 ++-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |  2 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  2 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  6 ++-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  | 12 ++---
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |  2 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |  2 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  2 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |  7 +--
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |  6 ++-
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 24 +++++-----
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  4 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |  2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 17 +++++---
 drivers/staging/lustre/lustre/ptlrpc/client.c      | 25 ++++++-----
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  8 ++--
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |  7 +--
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |  3 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    | 15 ++++---
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  2 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |  3 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  2 +-
 70 files changed, 425 insertions(+), 337 deletions(-)

-- 
1.8.3.1
