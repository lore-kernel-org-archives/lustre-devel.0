From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:26:59 -0400
Subject: [lustre-devel] [PATCH 03/20] lnet: use lnet_md_free in
 lnet_res_container_cleanup()
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

When we added lnet_md_free(), we should have called it
from lnet_res_container_cleanup() - but that was missed.
Fix it now.

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/lnet/lnet/api-ni.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 7c91800..d6694cb 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -927,12 +927,10 @@ static void lnet_assert_wire_constants(void)
 		struct list_head *e = rec->rec_active.next;
 
 		list_del_init(e);
-		if (rec->rec_type == LNET_COOKIE_TYPE_MD) {
-			kfree(list_entry(e, struct lnet_libmd, md_list));
-
-		} else { /* NB: Active MEs should be attached on portals */
+		if (rec->rec_type == LNET_COOKIE_TYPE_MD)
+			lnet_md_free(list_entry(e, struct lnet_libmd, md_list));
+		else /* NB: Active MEs should be attached on portals */
 			LBUG();
-		}
 		count++;
 	}
 
-- 
1.8.3.1
