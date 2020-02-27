From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:39 -0500
Subject: [lustre-devel] [PATCH 411/622] lnet: Convert noisy timeout error to
 cdebug
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-412-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

This error message in lnet_finalize_expired_responses is very noisy
when nodes go down or are rebooted, and it does not provide much value
to system administrators. Convert it to a CDEBUG instead

WC-bug-id: https://jira.whamcloud.com/browse/LU-12439
Lustre-commit: bd3ed8cb7165 ("LU-12439 lnet: Convert noisy timeout error to cdebug")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/35233
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 629856c..9a4c426 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2636,8 +2636,9 @@ struct lnet_mt_event_info {
 
 				nid = rspt->rspt_next_hop_nid;
 
-				CNETERR("Response timed out: md = %p: nid = %s\n",
-					md, libcfs_nid2str(nid));
+				CDEBUG(D_NET,
+				       "Response timeout: md = %p: nid = %s\n",
+				       md, libcfs_nid2str(nid));
 				LNetMDUnlink(rspt->rspt_mdh);
 				lnet_rspt_free(rspt, i);
 
-- 
1.8.3.1
