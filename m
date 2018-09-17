From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:31:13 -0400
Subject: [lustre-devel] [PATCH 0/8] lustre: obd: preprocessor cleanups
Message-ID: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The obd.h, obd_class.h, and clio headers are littered with complex
macros that are difficult to read. These macros existed to handle the
obd stats and md stats which are lacking in the linux client. Newer
versions do support md_stats so lets restore them as well as cleanup
the ugly macros. This patch set is order dependent and is based
on the first batch patch set for lustre 2.10 applied against the
lustre-testing branch.

Ben Evans (4):
  lustre: obdclass: remove CL_PAGE_INVOKE et. al.
  lustre: obdclass: remove cl_for_each defines
  lustre: obdclass: Code cleanup
  lustre: obdclass: cleanup obd_class.h defines

James Simmons (1):
  lustre: obdclass: restore md_stats code

John L. Hammond (3):
  lustre: obd: remove obd_{get,put}ref()
  lustre: obd: remove OBD ops based stats
  lustre: obd: add md_stats to MDC and LMV devices

 .../staging/lustre/lustre/include/lprocfs_status.h |   5 +-
 drivers/staging/lustre/lustre/include/obd.h        |  20 +-
 drivers/staging/lustre/lustre/include/obd_class.h  | 788 ++++++++++++---------
 drivers/staging/lustre/lustre/llite/file.c         |   2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   3 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   9 +-
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c      |   6 +
 drivers/staging/lustre/lustre/lov/lov_dev.c        |  12 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |   2 +
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  44 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  10 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |   4 +-
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |   7 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   8 +-
 drivers/staging/lustre/lustre/obdclass/Makefile    |   5 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  26 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  21 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   | 275 +++----
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   1 -
 drivers/staging/lustre/lustre/obdclass/genops.c    |   3 -
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |   7 +-
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |   4 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |  66 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   2 +-
 drivers/staging/lustre/lustre/obdclass/uuid.c      |  45 --
 25 files changed, 753 insertions(+), 622 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/uuid.c

-- 
1.8.3.1
