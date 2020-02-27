From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:37 -0500
Subject: [lustre-devel] [PATCH 289/622] lustre: ldlm: Fix style issues for
 ldlm_resource.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-290-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch
for file fs/lustre/ldlm/ldlm_resource.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: d7627feb4594 ("LU-6142 ldlm: Fix style issues for ldlm_resource.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/34492
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_resource.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 59b17b5..14e03bc 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -443,7 +443,7 @@ struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res)
 static unsigned int ldlm_res_hop_hash(struct cfs_hash *hs,
 				      const void *key, unsigned int mask)
 {
-	const struct ldlm_res_id *id  = key;
+	const struct ldlm_res_id *id = key;
 	unsigned int val = 0;
 	unsigned int i;
 
@@ -627,7 +627,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 		return NULL;
 	}
 
-	for (idx = 0;; idx++) {
+	for (idx = 0; ; idx++) {
 		nsd = &ldlm_ns_hash_defs[idx];
 		if (nsd->nsd_type == LDLM_NS_TYPE_UNKNOWN) {
 			CERROR("Unknown type %d for ns %s\n", ns_type, name);
@@ -770,7 +770,8 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
 			ldlm_set_local_only(lock);
 
 		if (local_only && (lock->l_readers || lock->l_writers)) {
-			/* This is a little bit gross, but much better than the
+			/*
+			 * This is a little bit gross, but much better than the
 			 * alternative: pretend that we got a blocking AST from
 			 * the server, so that when the lock is decref'd, it
 			 * will go away ...
-- 
1.8.3.1
