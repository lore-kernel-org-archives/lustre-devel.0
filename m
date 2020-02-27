From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:16 -0500
Subject: [lustre-devel] [PATCH 268/622] lustre: lov: Remove unnecessary
 assert
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-269-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

This is asserting on network data from the server, and
additionally, the LU-9846 (overstriping) work shows this
condition is not a problem if it does somehow occur.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11796
Lustre-commit: 1d7104485119 ("LU-11796 lov: Remove unnecessary assert")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33882
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_object.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index c6324f4..c04b2ae 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -210,7 +210,6 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 
 	spin_lock_init(&r0->lo_sub_lock);
 	r0->lo_nr = lse->lsme_stripe_count;
-	LASSERT(r0->lo_nr <= lov_targets_nr(dev));
 
 	r0->lo_sub = kcalloc(r0->lo_nr, sizeof(r0->lo_sub[0]),
 			     GFP_KERNEL);
-- 
1.8.3.1
