From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:45 -0400
Subject: [lustre-devel] [PATCH 00/18] fill in missing patches present in
	2.4.92 version
Message-ID: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

After the lustre client code was merged patches continued to land but
gaps did happen were several patches were missed. This batch of patches
are bug fixes that happened after the upstream client merger and before
the creation of lustre version 2.4.92 tag.

Aurelien Degremont (1):
  staging: lustre: hsm: copy start error should set HP_FLAG_COMPLETED

Gaurav Mahajan (1):
  staging: lustre: llite: Delaying creation of client side proc entries.

JC Lafoucriere (2):
  staging: lustre: hsm: rename hai_zero() HSM function
  staging: lustre: hsm: Add CLF_RENAME_LAST flag

James Simmons (1):
  staging: lustre: osc: Lustre returns EINTR from writes when SA_RESTART is set

Jinshan Xiong (7):
  staging: lustre: libcfs: remove userland comments in libcfs_debug.h
  staging: lustre: libcfs: create array of debug names
  staging: lustre: libcfs: make D_HSM a unique value
  staging: lustre: hsm: Fix lu_ref for lease handle
  staging: lustre: llite: reset writeback index in ll_writepages
  staging: lustre: llite: cancel open lock before closing file
  staging: lustre: hsm: Add support to drop all pages for ll_data_version

Ned Bass (1):
  staging: lustre: mdc: document mdc_rpc_lock

Niu Yawei (1):
  staging: lustre: llite: use 64bits flags in ll_lov_setea()

Sebastien Buisson (3):
  staging: lustre: ldlm: fix 'deadcode' errors
  staging: lustre: fix 'NULL pointer dereference' errors
  staging: lustre: fix 'no effect' errors

Swapnil Pimpale (1):
  staging: lustre: lov: Get the correct address of lmm_objects

 .../lustre/include/linux/libcfs/libcfs_debug.h     |   18 ++-
 drivers/staging/lustre/lnet/libcfs/debug.c         |  126 ++------------------
 .../lustre/lustre/include/lustre/lustre_idl.h      |    1 +
 .../lustre/lustre/include/lustre/lustre_user.h     |   18 ++-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   18 +++
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |    6 -
 drivers/staging/lustre/lustre/llite/dir.c          |   18 ++-
 drivers/staging/lustre/lustre/llite/file.c         |   59 ++++++----
 .../staging/lustre/lustre/llite/llite_internal.h   |    4 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   16 ++-
 drivers/staging/lustre/lustre/llite/rw.c           |    5 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |    9 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |    3 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c      |   11 ++
 drivers/staging/lustre/lustre/lov/lov_pack.c       |    3 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   42 +++++--
 19 files changed, 166 insertions(+), 197 deletions(-)
