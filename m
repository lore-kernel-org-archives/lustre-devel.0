From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Feb 2016 10:25:47 -0500
Subject: [lustre-devel] [PATCH 03/10] staging: lustre: fix failure handle of
	create reply
In-Reply-To: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
References: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455549954-29532-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

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
 drivers/staging/lustre/lnet/lnet/lib-move.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index ab56e7f..1e1e63c 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -2187,17 +2187,17 @@ lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *getmsg)
 	LASSERT(!getmsg->msg_target_is_router);
 	LASSERT(!getmsg->msg_routing);
 
-	cpt = lnet_cpt_of_cookie(getmd->md_lh.lh_cookie);
-	lnet_res_lock(cpt);
-
-	LASSERT(getmd->md_refcount > 0);
-
 	if (!msg) {
 		CERROR("%s: Dropping REPLY from %s: can't allocate msg\n",
 		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id));
 		goto drop;
 	}
 
+	cpt = lnet_cpt_of_cookie(getmd->md_lh.lh_cookie);
+	lnet_res_lock(cpt);
+
+	LASSERT(getmd->md_refcount > 0);
+
 	if (!getmd->md_threshold) {
 		CERROR("%s: Dropping REPLY from %s for inactive MD %p\n",
 		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id),
-- 
1.7.1
