From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:22 -0500
Subject: [lustre-devel] [PATCH 574/622] lustre: ldlm: simplify
 ldlm_ns_hash_defs[]
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-575-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

As the ldlm_ns_types are dense, we can use the type as
the index to the array, rather than searching through
the array for a match.
We can also discard nsd_hops as all hash tables now
use the same hops.
This makes the table smaller and the code simpler.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8130
Lustre-commit: 416142145c9d ("LU-8130 ldlm: simplify ldlm_ns_hash_defs[]")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36220
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_resource.c | 62 ++++++++++++++----------------------------
 1 file changed, 20 insertions(+), 42 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index d009d5d..9b24be7 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -522,55 +522,35 @@ static void ldlm_res_hop_put(struct cfs_hash *hs, struct hlist_node *hnode)
 	.hs_put		= ldlm_res_hop_put
 };
 
-struct ldlm_ns_hash_def {
-	enum ldlm_ns_type	nsd_type;
+static struct {
 	/** hash bucket bits */
 	unsigned int		nsd_bkt_bits;
 	/** hash bits */
 	unsigned int		nsd_all_bits;
-	/** hash operations */
-	struct cfs_hash_ops	*nsd_hops;
-};
-
-static struct ldlm_ns_hash_def ldlm_ns_hash_defs[] = {
-	{
-		.nsd_type       = LDLM_NS_TYPE_MDC,
+} ldlm_ns_hash_defs[] = {
+	[LDLM_NS_TYPE_MDC] = {
 		.nsd_bkt_bits   = 11,
 		.nsd_all_bits   = 16,
-		.nsd_hops       = &ldlm_ns_hash_ops,
 	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_MDT,
+	[LDLM_NS_TYPE_MDT] = {
 		.nsd_bkt_bits   = 14,
 		.nsd_all_bits   = 21,
-		.nsd_hops       = &ldlm_ns_hash_ops,
 	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_OSC,
+	[LDLM_NS_TYPE_OSC] = {
 		.nsd_bkt_bits   = 8,
 		.nsd_all_bits   = 12,
-		.nsd_hops       = &ldlm_ns_hash_ops,
 	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_OST,
+	[LDLM_NS_TYPE_OST] = {
 		.nsd_bkt_bits   = 11,
 		.nsd_all_bits   = 17,
-		.nsd_hops       = &ldlm_ns_hash_ops,
 	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_MGC,
+	[LDLM_NS_TYPE_MGC] = {
 		.nsd_bkt_bits   = 3,
 		.nsd_all_bits   = 4,
-		.nsd_hops       = &ldlm_ns_hash_ops,
 	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_MGT,
+	[LDLM_NS_TYPE_MGT] = {
 		.nsd_bkt_bits   = 3,
 		.nsd_all_bits   = 4,
-		.nsd_hops       = &ldlm_ns_hash_ops,
-	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_UNKNOWN,
 	},
 };
 
@@ -594,7 +574,6 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 					  enum ldlm_ns_type ns_type)
 {
 	struct ldlm_namespace *ns = NULL;
-	struct ldlm_ns_hash_def *nsd;
 	int idx;
 	int rc;
 
@@ -606,15 +585,10 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 		return NULL;
 	}
 
-	for (idx = 0; ; idx++) {
-		nsd = &ldlm_ns_hash_defs[idx];
-		if (nsd->nsd_type == LDLM_NS_TYPE_UNKNOWN) {
-			CERROR("Unknown type %d for ns %s\n", ns_type, name);
-			goto out_ref;
-		}
-
-		if (nsd->nsd_type == ns_type)
-			break;
+	if (ns_type >= ARRAY_SIZE(ldlm_ns_hash_defs) ||
+	    ldlm_ns_hash_defs[ns_type].nsd_bkt_bits == 0) {
+		CERROR("Unknown type %d for ns %s\n", ns_type, name);
+		goto out_ref;
 	}
 
 	ns = kzalloc(sizeof(*ns), GFP_NOFS);
@@ -622,11 +596,13 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 		goto out_ref;
 
 	ns->ns_rs_hash = cfs_hash_create(name,
-					 nsd->nsd_all_bits, nsd->nsd_all_bits,
-					 nsd->nsd_bkt_bits, 0,
+					 ldlm_ns_hash_defs[ns_type].nsd_all_bits,
+					 ldlm_ns_hash_defs[ns_type].nsd_all_bits,
+					 ldlm_ns_hash_defs[ns_type].nsd_bkt_bits,
+					 0,
 					 CFS_HASH_MIN_THETA,
 					 CFS_HASH_MAX_THETA,
-					 nsd->nsd_hops,
+					 &ldlm_ns_hash_ops,
 					 CFS_HASH_DEPTH |
 					 CFS_HASH_BIGNAME |
 					 CFS_HASH_SPIN_BKTLOCK |
@@ -634,7 +610,9 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	if (!ns->ns_rs_hash)
 		goto out_ns;
 
-	ns->ns_bucket_bits = nsd->nsd_all_bits - nsd->nsd_bkt_bits;
+	ns->ns_bucket_bits = ldlm_ns_hash_defs[ns_type].nsd_all_bits -
+			     ldlm_ns_hash_defs[ns_type].nsd_bkt_bits;
+
 	ns->ns_rs_buckets = kvmalloc(BIT(ns->ns_bucket_bits) *
 				     sizeof(ns->ns_rs_buckets[0]),
 				     GFP_KERNEL);
-- 
1.8.3.1
