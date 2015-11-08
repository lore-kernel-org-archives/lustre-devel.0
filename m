From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 18:09:36 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: remove unnecessary
	EXPORT_SYMBOL for lnet layer
Message-ID: <1447024177-2219-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

A lot of symbols don't need to be exported at all because they are
only used in the module they belong to.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5829
Reviewed-on: http://review.whamcloud.com/13320
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c     |    3 ---
 drivers/staging/lustre/lnet/lnet/lib-move.c   |    1 -
 drivers/staging/lustre/lnet/selftest/conctl.c |    2 --
 3 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 284150f..9f78dc8 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -354,7 +354,6 @@ lnet_counters_reset(void)
 
 	lnet_net_unlock(LNET_LOCK_EX);
 }
-EXPORT_SYMBOL(lnet_counters_reset);
 
 static char *
 lnet_res_type2str(int type)
@@ -1153,7 +1152,6 @@ lnet_init(void)
 	lnet_register_lnd(&the_lolnd);
 	return 0;
 }
-EXPORT_SYMBOL(lnet_init);
 
 /**
  * Finalize LNet library.
@@ -1177,7 +1175,6 @@ lnet_fini(void)
 
 	the_lnet.ln_init = 0;
 }
-EXPORT_SYMBOL(lnet_fini);
 
 /**
  * Set LNet PID and start LNet interfaces, routing, and forwarding.
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 5631f60..03a721e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1645,7 +1645,6 @@ lnet_msgtyp2str(int type)
 		return "<UNKNOWN>";
 	}
 }
-EXPORT_SYMBOL(lnet_msgtyp2str);
 
 void
 lnet_print_hdr(lnet_hdr_t *hdr)
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 556c837..a534665 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -925,5 +925,3 @@ out:
 
 	return rc;
 }
-
-EXPORT_SYMBOL(lstcon_ioctl_entry);
-- 
1.7.1
