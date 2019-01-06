From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:33 -0500
Subject: [lustre-devel] [PATCH 00/14] lustre: fixes for many test failures
Message-ID: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch series contains mostly fixes to resolve the majority of
the testing failures seen. Besides that are UAPI headers fixes to
prepare for when lustre will leave the staging tree. Include Neil's
dump_page_cache patch as well since it was landed in the OpenSFS
branch and the migration of lu_objects to rhashtables depended on
it.

James Simmons (9):
  lustre: uapi: replace cfs_size_* macros with __ALIGN_KERNEL
  lustre: uapi: final fixes for UAPI support.
  lustre: llite: op_data->op_valid is incorrect in ll_dir_getstripe
  lustre: llite: return correct amount of bytes for short operations
  lustre: llite: user xattr_prefix() to create xattr full name
  lustre: llite: conditionally set it_flags in ll_file_open
  lustre: llite: fix file migration
  lustre: sysfs: temporary work around for sysfs naming
  lustre: libcfs: hide struct cfs_cpt_table internals

John L. Hammond (1):
  lustre: llite: add LL_IOC_FUTIMES_3

Lai Siyao (1):
  lustre: llite: improve getdirstripe interface

Minh Diep (1):
  lustre: uapi: fix lustre_user.h to C++ compatible

NeilBrown (1):
  lustre: llite: change how "dump_page_cache" walks a hash table

Patrick Farrell (1):
  lustre: llite: Add S_NOSEC support

 .../lustre/include/linux/libcfs/libcfs_cpu.h       |  39 +----
 .../staging/lustre/include/linux/lnet/lib-types.h  |   1 +
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |   1 -
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  14 +-
 .../lustre/include/uapi/linux/lustre/lustre_user.h |  57 ++++---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |  34 ++++
 .../staging/lustre/lustre/include/obd_support.h    |   2 +
 drivers/staging/lustre/lustre/llite/dir.c          |   3 +-
 drivers/staging/lustre/lustre/llite/file.c         |  53 ++++++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  25 ++-
 drivers/staging/lustre/lustre/llite/namei.c        |   1 +
 drivers/staging/lustre/lustre/llite/vvp_dev.c      | 173 ++++++++++-----------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  10 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   4 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   1 -
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |   2 +-
 17 files changed, 249 insertions(+), 173 deletions(-)

-- 
1.8.3.1
