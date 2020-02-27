From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:01 -0500
Subject: [lustre-devel] [PATCH 013/622] lustre: obdclass: fix
 llog_cat_cleanup() usage on Client
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

With patch/commit 3a83b4b9 for LU-5195, LLOG code has been
strengthen against catalog inconsistency by detecting a
referenced plain LLOG is missing and by clearing its
associated entry by calling llog_cat_cleanup(), which now
needs to handle the case where it is also executed on a Client
(ie, cathandle->lgh_obj == NULL) and thus must not attempt to
update on-disk catalog.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6471
Lustre-commit: 485f3ba87433 ("LU-6471 obdclass: fix llog_cat_cleanup() usage on Client")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: http://review.whamcloud.com/14489
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog_cat.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/obdclass/llog_cat.c b/fs/lustre/obdclass/llog_cat.c
index 580d807..ca97e08 100644
--- a/fs/lustre/obdclass/llog_cat.c
+++ b/fs/lustre/obdclass/llog_cat.c
@@ -133,10 +133,8 @@ int llog_cat_close(const struct lu_env *env, struct llog_handle *cathandle)
 		list_del_init(&loghandle->u.phd.phd_entry);
 		llog_close(env, loghandle);
 	}
-	/* if handle was stored in ctxt, remove it too */
-	if (cathandle->lgh_ctxt->loc_handle == cathandle)
-		cathandle->lgh_ctxt->loc_handle = NULL;
-	return llog_close(env, cathandle);
+
+	return 0;
 }
 EXPORT_SYMBOL(llog_cat_close);
 
-- 
1.8.3.1
