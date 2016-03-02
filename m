From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:49 -0500
Subject: [lustre-devel] [PATCH 06/27] staging: lustre: Use after free in
	lnet_ptl_match_delay()
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Olaf Weber <olaf@sgi.com>

From: Olaf Weber <olaf@sgi.com>

In lnet_ptl_match_delay() we check msg->msg_rx_delayed to see whether
the message has been added to the delay queue. But this check is done
after lnet_ptl_unlock() and lnet_res_unlock(), and the message can be
processed and freed before the check.

Replace the check with checking rc against LNET_MATCHMD_NONE, which
is how the callers of lnet_ptl_match_delay() know whether the message
was added to the delay queue. To make this work we reset rc in the
loop when there was no match and the message hasn't been delayed. In
addition reorganize the code and add comments to clarify the logic.

In lnet_ptl_match_md() a similar msg->msg_rx_delayed is replaced for
the same reason.

Signed-off-by: Olaf Weber <olaf@sgi.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7324
Reviewed-on: http://review.whamcloud.com/17840
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-ptl.c |   84 +++++++++++++++++----------
 1 files changed, 53 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 0281c6a..2b41205 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -472,10 +472,12 @@ lnet_ptl_match_delay(struct lnet_portal *ptl,
 	int rc = 0;
 	int i;
 
-	/*
-	 * steal buffer from other CPTs, and delay it if nothing to steal,
-	 * this function is more expensive than a regular match, but we
-	 * don't expect it can happen a lot
+	/**
+	 * Steal buffer from other CPTs, and delay msg if nothing to
+	 * steal. This function is more expensive than a regular
+	 * match, but we don't expect it can happen a lot. The return
+	 * code contains one of LNET_MATCHMD_OK, LNET_MATCHMD_DROP, or
+	 * LNET_MATCHMD_NONE.
 	 */
 	LASSERT(lnet_ptl_is_wildcard(ptl));
 
@@ -491,52 +493,71 @@ lnet_ptl_match_delay(struct lnet_portal *ptl,
 		lnet_res_lock(cpt);
 		lnet_ptl_lock(ptl);
 
-		if (!i) { /* the first try, attach on stealing list */
+		if (!i) {
+			/* The first try, add to stealing list. */
 			list_add_tail(&msg->msg_list,
 				      &ptl->ptl_msg_stealing);
 		}
 
-		if (!list_empty(&msg->msg_list)) { /* on stealing list */
+		if (!list_empty(&msg->msg_list)) {
+			/* On stealing list. */
 			rc = lnet_mt_match_md(mtable, info, msg);
 
 			if ((rc & LNET_MATCHMD_EXHAUSTED) &&
 			    mtable->mt_enabled)
 				lnet_ptl_disable_mt(ptl, cpt);
 
-			if (rc & LNET_MATCHMD_FINISH)
+			if (rc & LNET_MATCHMD_FINISH) {
+				/* Match found, remove from stealing list. */
+				list_del_init(&msg->msg_list);
+			} else if (i == LNET_CPT_NUMBER - 1 ||	/* (1) */
+				   !ptl->ptl_mt_nmaps ||	/* (2) */
+				   (ptl->ptl_mt_nmaps == 1 &&	/* (3) */
+				    ptl->ptl_mt_maps[0] == cpt)) {
+				/**
+				 * No match found, and this is either
+				 * (1) the last cpt to check, or
+				 * (2) there is no active cpt, or
+				 * (3) this is the only active cpt.
+				 * There is nothing to steal: delay or
+				 * drop the message.
+				 */
 				list_del_init(&msg->msg_list);
 
+				if (lnet_ptl_is_lazy(ptl)) {
+					msg->msg_rx_delayed = 1;
+					list_add_tail(&msg->msg_list,
+						      &ptl->ptl_msg_delayed);
+					rc = LNET_MATCHMD_NONE;
+				} else {
+					rc = LNET_MATCHMD_DROP;
+				}
+			} else {
+				/* Do another iteration. */
+				rc = 0;
+			}
 		} else {
-			/*
-			 * could be matched by lnet_ptl_attach_md()
-			 * which is called by another thread
+			/**
+			 * No longer on stealing list: another thread
+			 * matched the message in lnet_ptl_attach_md().
+			 * We are now expected to handle the message.
 			 */
 			rc = !msg->msg_md ?
 			     LNET_MATCHMD_DROP : LNET_MATCHMD_OK;
 		}
 
-		if (!list_empty(&msg->msg_list) && /* not matched yet */
-		    (i == LNET_CPT_NUMBER - 1 || /* the last CPT */
-		     !ptl->ptl_mt_nmaps ||   /* no active CPT */
-		     (ptl->ptl_mt_nmaps == 1 &&  /* the only active CPT */
-		      ptl->ptl_mt_maps[0] == cpt))) {
-			/* nothing to steal, delay or drop */
-			list_del_init(&msg->msg_list);
-
-			if (lnet_ptl_is_lazy(ptl)) {
-				msg->msg_rx_delayed = 1;
-				list_add_tail(&msg->msg_list,
-					      &ptl->ptl_msg_delayed);
-				rc = LNET_MATCHMD_NONE;
-			} else {
-				rc = LNET_MATCHMD_DROP;
-			}
-		}
-
 		lnet_ptl_unlock(ptl);
 		lnet_res_unlock(cpt);
 
-		if ((rc & LNET_MATCHMD_FINISH) || msg->msg_rx_delayed)
+		/**
+		 * Note that test (1) above ensures that we always
+		 * exit the loop through this break statement.
+		 *
+		 * LNET_MATCHMD_NONE means msg was added to the
+		 * delayed queue, and we may no longer reference it
+		 * after lnet_ptl_unlock() and lnet_res_unlock().
+		 */
+		if (rc & (LNET_MATCHMD_FINISH | LNET_MATCHMD_NONE))
 			break;
 	}
 
@@ -598,13 +619,14 @@ lnet_ptl_match_md(struct lnet_match_info *info, struct lnet_msg *msg)
 
 		lnet_ptl_unlock(ptl);
 		lnet_res_unlock(mtable->mt_cpt);
-
+		rc = LNET_MATCHMD_NONE;
 	} else  {
 		lnet_res_unlock(mtable->mt_cpt);
 		rc = lnet_ptl_match_delay(ptl, info, msg);
 	}
 
-	if (msg->msg_rx_delayed) {
+	/* LNET_MATCHMD_NONE means msg was added to the delay queue */
+	if (rc & LNET_MATCHMD_NONE) {
 		CDEBUG(D_NET,
 		       "Delaying %s from %s ptl %d MB %#llx off %d len %d\n",
 		       info->mi_opc == LNET_MD_OP_PUT ? "PUT" : "GET",
-- 
1.7.1
