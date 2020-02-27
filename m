From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:46 -0500
Subject: [lustre-devel] [PATCH 418/622] lnet: Detach rspt when md_threshold
 is infinite
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-419-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

MDs for pings use the infinite threshold on MD operations.
As such they aren't normally unlinkable as determined by
lnet_md_unlinkable(). We can cover this case by checking whether the
refcount is zero and threshold is LNET_MD_THRESH_INF.

Cray-bug-id: LUS-7366
WC-bug-id: https://jira.whamcloud.com/browse/LU-12441
Lustre-commit: ebbf909a1c2d ("LU-12441 lnet: Detach rspt when md_threshold is infinite")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/35452
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-msg.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index b70a6c9..805d5b9 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -825,10 +825,12 @@
 		lnet_eq_enqueue_event(md->md_eq, &msg->msg_ev);
 	}
 
-	if (unlink) {
+	if (unlink || (md->md_refcount == 0 &&
+		       md->md_threshold == LNET_MD_THRESH_INF))
 		lnet_detach_rsp_tracker(md, cpt);
+
+	if (unlink)
 		lnet_md_unlink(md);
-	}
 
 	msg->msg_md = NULL;
 }
-- 
1.8.3.1
