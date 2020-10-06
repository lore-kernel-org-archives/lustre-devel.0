From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:20 -0400
Subject: [lustre-devel] [PATCH 41/42] lustre: obdclass: don't initialize obj
 for zero FID
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-42-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Object with zero FID is used in stripe allocation, and it's
meaningless to initialize such object via lu_object_find_at(),
return error early to avoid assertion in lu_object_put().

WC-bug-id: https://jira.whamcloud.com/browse/LU-13511
Lustre-commit: 22ea9767956c89 ("LU-13511 obdclass: don't initialize obj for zero FID")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39792
Reviewed-by: Stephane Thiell <sthiell@stanford.edu>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lu_object.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 42bb7a6..e8fc328 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -780,6 +780,13 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	struct rhashtable *hs;
 	int rc;
 
+	/* FID is from disk or network, zero FID is meaningless, return error
+	 * early to avoid assertion in lu_object_put. If a zero FID is wanted,
+	 * it should be allocated via lu_object_anon().
+	 */
+	if (fid_is_zero(f))
+		return ERR_PTR(-EINVAL);
+
 	/*
 	 * This uses standard index maintenance protocol:
 	 *
-- 
1.8.3.1
