From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:19 -0500
Subject: [lustre-devel] [PATCH 391/622] lustre: lov: Correct bounds checking
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-392-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Nathaniel Clark <nclark@whamcloud.com>

While Dan Carpenter ran his smatch tool against the lustre code
base he encountered the following static checker warning:

fs/lustre/lov/lov_ea.c:207 lsm_unpackmd_common()
warn: signed overflow undefined. 'min_stripe_maxbytes * stripe_count < min_stripe_maxbytes'

The current code doesn't properly handle the potential overflow
with the min_stripe_maxbytes * stripe_count. This fixes the
overflow detection for maxbytes in lsme_unpack().

Fixes: 476f575cf070 ("staging: lustre: lov: Ensure correct operation for large object sizes")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9862
Lustre-commit: 31ff883c7b0c ("LU-9862 lov: Correct bounds checking")
Signed-off-by: Nathaniel Clark <nclark@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28484
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_ea.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index 07bfe0f..4be01bb8 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -274,15 +274,16 @@ void lsm_free(struct lov_stripe_md *lsm)
 	if (min_stripe_maxbytes == 0)
 		min_stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
 
-	lov_bytes = min_stripe_maxbytes * stripe_count;
+	if (stripe_count == 0)
+		lov_bytes = min_stripe_maxbytes;
+	else if (min_stripe_maxbytes <= LLONG_MAX / stripe_count)
+		lov_bytes = min_stripe_maxbytes * stripe_count;
+	else
+		lov_bytes = MAX_LFS_FILESIZE;
 
 out_dom:
-	if (maxbytes) {
-		if (lov_bytes < min_stripe_maxbytes) /* handle overflow */
-			*maxbytes = MAX_LFS_FILESIZE;
-		else
-			*maxbytes = lov_bytes;
-	}
+	if (maxbytes)
+		*maxbytes = min_t(loff_t, lov_bytes, MAX_LFS_FILESIZE);
 
 	return lsme;
 
-- 
1.8.3.1
