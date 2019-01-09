From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:01 +1100
Subject: [lustre-devel] [PATCH 04/29] lustre: osc: simplify list manipulation
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504121.26726.13780223132597872019.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

when A is empty,
 list_move_tail(&A, &B);
is identical to
 list_add_tail(&A, &B);

so always use list_move_tail() - it is easier to understand.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 00056dffceb9..6771675dd520 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2885,10 +2885,7 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
 		}
 		/* This extent could be on the full extents list, that's OK */
 		EASSERT(!ext->oe_hp && !ext->oe_urgent, ext);
-		if (!list_empty(&ext->oe_link))
-			list_move_tail(&ext->oe_link, &list);
-		else
-			list_add_tail(&ext->oe_link, &list);
+		list_move_tail(&ext->oe_link, &list);
 
 		ext = next_extent(ext);
 	}
