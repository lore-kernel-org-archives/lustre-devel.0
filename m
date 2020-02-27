From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:15 -0500
Subject: [lustre-devel] [PATCH 027/622] lustre: lu_object: improve debug
 message for lu_object_put()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

Use a top level object in debug in lu_object_put to match with
lu_object_get.

WC-bug-id: https://jira.whamcloud.com/browse/LU-LU-10877
Lustre-commit: fd669eba1921 ("LU-10877 lu: fix reference leak")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/31870
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Sergey Cheremencev <c17829@cray.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lu_object.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index d8dfc721..2ab4977 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -184,8 +184,8 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 		LASSERT(list_empty(&top->loh_lru));
 		list_add_tail(&top->loh_lru, &bkt->lsb_lru);
 		percpu_counter_inc(&site->ls_lru_len_counter);
-		CDEBUG(D_INODE, "Add %p to site lru. hash: %p, bkt: %p\n",
-		       o, site->ls_obj_hash, bkt);
+		CDEBUG(D_INODE, "Add %p/%p to site lru. hash: %p, bkt: %p\n",
+		       orig, top, site->ls_obj_hash, bkt);
 		cfs_hash_bd_unlock(site->ls_obj_hash, &bd, 1);
 		return;
 	}
-- 
1.8.3.1
