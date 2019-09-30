From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:03 -0400
Subject: [lustre-devel] [PATCH 104/151] lustre: lov: fill no-extent fiemap
 on object with no stripe.
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-105-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dominique Martinet <dominique.martinet@cea.fr>

This is useful for cp of large sparse files with no stripe info,
as cp relies on fiemap to detect what to read.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10405
Lustre-commit: 113fa79b7dc9 ("LU-10405 lov: fill no-extent fiemap on object with no stripe")
Signed-off-by: Dominique Martinet <dominique.martinet@cea.fr>
Reviewed-on: https://review.whamcloud.com/30591
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_object.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index d3ed5fc..51b95f2 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -1774,8 +1774,11 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	struct fiemap_state fs = { NULL };
 
 	lsm = lov_lsm_addref(cl2lov(obj));
-	if (!lsm)
-		return -ENODATA;
+	if (!lsm) {
+		/* no extent: there is no object for mapping */
+		fiemap->fm_mapped_extents = 0;
+		return 0;
+	}
 
 	if (!(fiemap->fm_flags & FIEMAP_FLAG_DEVICE_ORDER)) {
 		/**
-- 
1.8.3.1
