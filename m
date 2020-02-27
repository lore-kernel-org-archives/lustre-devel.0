From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:48 -0500
Subject: [lustre-devel] [PATCH 300/622] lustre: dom: mdc_lock_flush()
 improvement
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-301-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

There is small improvement in osc_lock_flush() to don't
match other locks for write lock because there are none.

Do the same in mdc_lock_flush().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10894
Lustre-commit: 276221c2a1d2 ("LU-10894 dom: mdc_lock_flush() improvement")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34738
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_dev.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 8f0e283..14cece1 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -253,7 +253,9 @@ static int mdc_lock_flush(const struct lu_env *env, struct osc_object *obj,
 			result = 0;
 	}
 
-	rc = mdc_lock_discard_pages(env, obj, start, end, discard);
+	/* Avoid lock matching with CLM_WRITE, there can be no other locks */
+	rc = mdc_lock_discard_pages(env, obj, start, end,
+				    mode == CLM_WRITE || discard);
 	if (result == 0 && rc < 0)
 		result = rc;
 
-- 
1.8.3.1
