From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:48 -0500
Subject: [lustre-devel] [PATCH 180/622] lustre: osc: speed up page cache
 cleanup during blocking ASTs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-181-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andrew Perepechko <c17827@cray.com>

While we are cleaning a write lock, we don't need to check if
page cache pages under this lock are covered by another lock.

If a client needs to give up its lock, cleaning gigabytes of
page cache can take quite a long time.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11296
Lustre-commit: b9ebb17277c7 ("LU-11296 osc: speed up page cache cleanup during blocking ASTs")
Signed-off-by: Andrew Perepechko <c17827@cray.com>
Cray-bug-id: LUS-6352
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-on: https://review.whamcloud.com/33090
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_lock.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 1a2b0bd..eccea37 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -372,7 +372,12 @@ static int osc_lock_flush(struct osc_object *obj, pgoff_t start, pgoff_t end,
 			rc = 0;
 	}
 
-	rc2 = osc_lock_discard_pages(env, obj, start, end, discard);
+	/*
+	 * Do not try to match other locks with CLM_WRITE since we already
+	 * know there're none
+	 */
+	rc2 = osc_lock_discard_pages(env, obj, start, end,
+				     mode == CLM_WRITE || discard);
 	if (rc == 0 && rc2 < 0)
 		rc = rc2;
 
-- 
1.8.3.1
