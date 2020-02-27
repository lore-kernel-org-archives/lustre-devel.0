From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:47 -0500
Subject: [lustre-devel] [PATCH 479/622] lustre: osc: prevent use after free
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-480-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

Clear aa_oa after it's been freed to prevent use after free.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12581
Lustre-commit: 61c9f8797771 ("LU-12581 osc: prevent use after free")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35601
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 75e0823..7ba9ea5 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -748,6 +748,7 @@ static int osc_shrink_grant_interpret(const struct lu_env *env,
 	osc_update_grant(cli, body);
 out:
 	kmem_cache_free(osc_obdo_kmem, aa->aa_oa);
+	aa->aa_oa = NULL;
 
 	return rc;
 }
@@ -2131,6 +2132,7 @@ static int brw_interpret(const struct lu_env *env,
 		cl_object_attr_unlock(obj);
 	}
 	kmem_cache_free(osc_obdo_kmem, aa->aa_oa);
+	aa->aa_oa = NULL;
 
 	if (lustre_msg_get_opc(req->rq_reqmsg) == OST_WRITE && rc == 0)
 		osc_inc_unstable_pages(req);
-- 
1.8.3.1
