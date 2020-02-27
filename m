From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:39 -0500
Subject: [lustre-devel] [PATCH 051/622] lustre: ldlm: Reduce debug to
 console during eviction
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-52-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

During an eviction, Lustre calls ldlm_namespace_cleanup,
and it will sometimes end up dumping all of the locks on a
particular resource to the console log
(ldlm_resource_complain), which is very wasteful and only
rarely helpful.

Move the debug level for this to D_NETERROR since it is in the
default debug mask.

Cray-bug-id: LUS-1418
WC-bug-id: https://jira.whamcloud.com/browse/LU-10648
Lustre-commit: f92fcb863cb9 ("LU-10648 ldlm: Reduce debug to console during eviction")
Signed-off-by: Chris Horn <hornc@cray.com>
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31237
Reviewed-by: Sergey Cheremencev <c17829@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_resource.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 7fe8a8b..5d73132 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -819,7 +819,8 @@ static int ldlm_resource_complain(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 	       ldlm_ns_name(ldlm_res_to_ns(res)), PLDLMRES(res), res,
 	       atomic_read(&res->lr_refcount) - 1);
 
-	ldlm_resource_dump(D_ERROR, res);
+	/* Use D_NETERROR since it is in the default mask */
+	ldlm_resource_dump(D_NETERROR, res);
 	unlock_res(res);
 	return 0;
 }
-- 
1.8.3.1
