From: James Simmons <jsimmons@infradead.org>
Date: Fri, 26 Feb 2016 11:36:00 -0500
Subject: [lustre-devel] [PATCH v3 0/6] staging: lustre: update modinfo data
Message-ID: <1456504566-21176-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The module information for Lustre is stale or in some cases
completely missing. This collection of patches brings the
modinfo up to date as well as filling in any missing information.
This patch set has been redone to rebase it on Oleg's latest
patch set to avoid collisons in merging.

Changelog:
 V1) Initial patch set based on last commit to staging
     c4e315884ed8524a4d4660bf4d9f37cfb750959a

 V2) Second patch set rebased on top of Oleg's outstanding
     patch to avoid a collisions with class_obd.c changes
     done in both patch sets.

 V3) Rebased this patch set to staging commit
     2cda64cf6998a1d10961f69e2ac79c69b6d37795 now that the
     patches from Oleg that collide have now been merged

Andreas Dilger (4):
  staging: lustre: add missing MODULE_AUTHOR for LNet selftest module
  staging: lustre: update the MODULE_DESCRIPTION for all lustre modules
  staging: lustre: make module_init/exit naming consistent
  staging: lustre: update comment for lnet_lib_init/exit

James Simmons (2):
  staging: lustre: move module info to end of libcfs module.c file
  staging: lustre: update the MODULE_VERSION for all lustre modules

 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 ++
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    4 ++--
 drivers/staging/lustre/include/linux/lnet/types.h  |    2 ++
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   11 ++++++-----
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   14 ++++++--------
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   13 ++++++-------
 drivers/staging/lustre/lnet/lnet/module.c          |   20 +++++++++-----------
 drivers/staging/lustre/lnet/selftest/module.c      |    9 +++++----
 drivers/staging/lustre/lustre/fid/fid_request.c    |   12 ++++++------
 drivers/staging/lustre/lustre/fld/fld_request.c    |   11 ++++++-----
 drivers/staging/lustre/lustre/libcfs/module.c      |   17 ++++++++---------
 drivers/staging/lustre/lustre/llite/lloop.c        |    7 ++++---
 drivers/staging/lustre/lustre/llite/super25.c      |   11 ++++++-----
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    3 ++-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    1 +
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    1 +
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   12 ++++++------
 .../staging/lustre/lustre/obdecho/echo_client.c    |    4 ++--
 .../staging/lustre/lustre/ptlrpc/ptlrpc_module.c   |    2 +-
 20 files changed, 82 insertions(+), 76 deletions(-)
