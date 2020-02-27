From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:52 -0500
Subject: [lustre-devel] [PATCH 364/622] lustre: lov: return error if
 cl_env_get fails
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-365-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shaun Tancheff <stancheff@cray.com>

When cl_env_get() fails with an error return the error.

Cray-bug-id: LUS-7310
WC-bug-id: https://jira.whamcloud.com/browse/LU-12436
Lustre-commit: a7997c836bbf ("LU-12436 lov: return error if cl_env_get fails")
Signed-off-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-on: https://review.whamcloud.com/35229
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_io.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 5b28793..9cdfca1 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -120,8 +120,10 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 
 	/* obtain new environment */
 	sub->sub_env = cl_env_get(&sub->sub_refcheck);
-	if (IS_ERR(sub->sub_env))
+	if (IS_ERR(sub->sub_env)) {
 		rc = PTR_ERR(sub->sub_env);
+		return rc;
+	}
 
 	sub_obj = lovsub2cl(lov_r0(lov, index)->lo_sub[stripe]);
 	sub_io = &sub->sub_io;
-- 
1.8.3.1
