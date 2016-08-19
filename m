From: James Simmons <jsimmons@infradead.org>
Date: Fri, 19 Aug 2016 14:07:24 -0400
Subject: [lustre-devel] [PATCH 0/7] staging: lustre: last missing patches
	for lustre 2.6
Message-ID: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Resolved the last remain bug that prevented earlier submission.
This covers the remaining patches that were missing from the
upstream client that was in Lustre 2.6 except for the work for
LU-2484. The work for LU-2484 depends on the stat infrastructure
that was removed earlier from the upstream client. That will
be done at a later date. In reality this is a pre-2.7 client
due to the landing of many patches earlier from lustre 2.7.
In any case this is a huge milestone for the lustre client in
the linux kernel.

James Simmons (1):
  staging: lustre: update version to 2.5.99

Jian Yu (1):
  staging: lustre: obd: remove unused lmv_readpages()/mdc_readpage()

John L. Hammond (2):
  staging: lustre: obd: remove dead code
  staging: lustre: obd: decruft md_enqueue() and md_intent_lock()

wang di (3):
  staging: lustre: lmv: implement lmv version of read_page
  staging: lustre: llite: move dir cache to MDC layer
  staging: lustre: mdt: add OBD_CONNECT_DIR_STRIPE flag

 .../lustre/lustre/include/lustre/lustre_idl.h      |    7 +-
 .../staging/lustre/lustre/include/lustre_import.h  |   22 -
 .../staging/lustre/lustre/include/lustre_lite.h    |   11 -
 drivers/staging/lustre/lustre/include/lustre_log.h |    3 +-
 .../lustre/lustre/include/lustre_req_layout.h      |    3 -
 drivers/staging/lustre/lustre/include/lustre_ver.h |    4 +-
 drivers/staging/lustre/lustre/include/obd.h        |   71 +---
 drivers/staging/lustre/lustre/include/obd_class.h  |   67 +--
 .../staging/lustre/lustre/include/obd_support.h    |    1 -
 drivers/staging/lustre/lustre/llite/dir.c          |  334 +------------
 drivers/staging/lustre/lustre/llite/file.c         |   39 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    3 +-
 drivers/staging/lustre/lustre/llite/namei.c        |    4 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   12 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |   12 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   50 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    3 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  479 +++++++++++-------
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   20 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   15 -
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   47 +--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  516 ++++++++++++++++++--
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   25 -
 .../lustre/lustre/obdclass/linux/linux-obdo.c      |    2 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 +
 .../staging/lustre/lustre/obdclass/obd_config.c    |   16 +-
 drivers/staging/lustre/lustre/obdclass/obdo.c      |    7 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    1 -
 drivers/staging/lustre/lustre/osc/osc_request.c    |   12 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   17 -
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    2 +
 32 files changed, 912 insertions(+), 897 deletions(-)
