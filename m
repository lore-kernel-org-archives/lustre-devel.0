From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:24 -0500
Subject: [lustre-devel] [PATCH 456/622] lustre: fld: remove fci_no_shrink
 field.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-457-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This field is never set, so is always zero.
Remove it, and the one place where it is tested.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: e669586775c6 ("LU-6142 fld: remove fci_no_shrink field.")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35875
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fld/fld_cache.c    | 3 +--
 fs/lustre/fld/fld_internal.h | 1 -
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/lustre/fld/fld_cache.c b/fs/lustre/fld/fld_cache.c
index 5267ba2..79b10bb 100644
--- a/fs/lustre/fld/fld_cache.c
+++ b/fs/lustre/fld/fld_cache.c
@@ -381,8 +381,7 @@ static int fld_cache_insert_nolock(struct fld_cache *cache,
 	 * insertion loop.
 	 */
 
-	if (!cache->fci_no_shrink)
-		fld_cache_shrink(cache);
+	fld_cache_shrink(cache);
 
 	head = &cache->fci_entries_head;
 
diff --git a/fs/lustre/fld/fld_internal.h b/fs/lustre/fld/fld_internal.h
index 465c6ccf..53648d2 100644
--- a/fs/lustre/fld/fld_internal.h
+++ b/fs/lustre/fld/fld_internal.h
@@ -109,7 +109,6 @@ struct fld_cache {
 
 	/** Cache name used for debug and messages. */
 	char			fci_name[LUSTRE_MDT_MAXNAMELEN];
-	unsigned int		fci_no_shrink:1;
 };
 
 enum {
-- 
1.8.3.1
