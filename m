From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:40 -0500
Subject: [lustre-devel] [PATCH 04/40] staging: lustre: fix failure handle of
	create reply
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Liang Zhen <liang.zhen@intel.com>

error handler of lnet_create_reply_msg() didn't release lnet_res_lock
if lnet_msg_alloc() failed.
It can be fixed by moving validation check of msg out from lock.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2745
Reviewed-on: http://review.whamcloud.com/5542
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index c56de44..03fcddc 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -2160,17 +2160,17 @@ lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *getmsg)
 	LASSERT(!getmsg->msg_target_is_router);
 	LASSERT(!getmsg->msg_routing);
 
-	cpt = lnet_cpt_of_cookie(getmd->md_lh.lh_cookie);
-	lnet_res_lock(cpt);
-
-	LASSERT(getmd->md_refcount > 0);
-
 	if (msg == NULL) {
 		CERROR("%s: Dropping REPLY from %s: can't allocate msg\n",
-			libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id));
+		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id));
 		goto drop;
 	}
 
+	cpt = lnet_cpt_of_cookie(getmd->md_lh.lh_cookie);
+	lnet_res_lock(cpt);
+
+	LASSERT(getmd->md_refcount > 0);
+
 	if (getmd->md_threshold == 0) {
 		CERROR("%s: Dropping REPLY from %s for inactive MD %p\n",
 			libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id),
-- 
1.7.1
