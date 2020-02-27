From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:58 -0500
Subject: [lustre-devel] [PATCH 550/622] lustre: ldlm: separate buckets from
 ldlm hash table
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-551-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

ldlm maintains a per-namespace hashtable of resources.
With these hash tables it stores per-bucket 'struct adaptive_timeout'
structures.

Presumably having a single struct for the whole table results in too
much contention while having one per resource results in very little
adaption.

A future patch will change ldlm to use rhashtable which does not
support per-bucket data, so we need to manage the data separately.

There is no need for the multiple adaptive_timeout to align with the
hash chains, and trying to do this has resulted in a rather complex
hash function.
The purpose of ldlm_res_hop_fid_hash() appears to be to keep
resources with the same fid in the same hash bucket, so they use
the same adaptive timeout.  However it fails at doing this
because it puts the fid-specific bits in the wrong part of the hash.
If that is not the purpose, then I can see no point to the
complexitiy.

This patch creates a completely separate array of adaptive timeouts
(and other less interesting data) and uses a hash of the fid to index
that, meaning that a simple hash can be used for the hash table.

In the previous code, two namespace uses the same value for
nsd_all_bits and nsd_bkt_bits.  This results in zero bits being
used to choose a bucket - so there is only one bucket.
This looks odd and would confuse hash_32(), so I've adjusted the
numbers so there is always at least 1 bit (2 buckets).

WC-bug-id: https://jira.whamcloud.com/browse/LU-8130
Lustre-commit: d234e2cf5f55 ("LU-8130 ldlm: separate buckets from ldlm hash table")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36218
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h |  2 ++
 fs/lustre/ldlm/ldlm_resource.c | 56 ++++++++++++++++++------------------------
 2 files changed, 26 insertions(+), 32 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 31d360e..cc4b8b0 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -364,6 +364,8 @@ struct ldlm_namespace {
 
 	/** Resource hash table for namespace. */
 	struct cfs_hash		*ns_rs_hash;
+	struct ldlm_ns_bucket	*ns_rs_buckets;
+	unsigned int		ns_bucket_bits;
 
 	/** serialize */
 	spinlock_t		ns_lock;
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 14e03bc..65ff32c 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -452,10 +452,9 @@ static unsigned int ldlm_res_hop_hash(struct cfs_hash *hs,
 	return val & mask;
 }
 
-static unsigned int ldlm_res_hop_fid_hash(struct cfs_hash *hs,
-					  const void *key, unsigned int mask)
+static unsigned int ldlm_res_hop_fid_hash(const struct ldlm_res_id *id,
+					  unsigned int bits)
 {
-	const struct ldlm_res_id *id = key;
 	struct lu_fid fid;
 	u32 hash;
 	u32 val;
@@ -468,18 +467,11 @@ static unsigned int ldlm_res_hop_fid_hash(struct cfs_hash *hs,
 	hash += (hash >> 4) + (hash << 12); /* mixing oid and seq */
 	if (id->name[LUSTRE_RES_ID_HSH_OFF] != 0) {
 		val = id->name[LUSTRE_RES_ID_HSH_OFF];
-		hash += (val >> 5) + (val << 11);
 	} else {
 		val = fid_oid(&fid);
 	}
-	hash = hash_long(hash, hs->hs_bkt_bits);
-	/* give me another random factor */
-	hash -= hash_long((unsigned long)hs, val % 11 + 3);
-
-	hash <<= hs->hs_cur_bits - hs->hs_bkt_bits;
-	hash |= ldlm_res_hop_hash(hs, key, CFS_HASH_NBKT(hs) - 1);
-
-	return hash & mask;
+	hash += (val >> 5) + (val << 11);
+	return hash_32(hash, bits);
 }
 
 static void *ldlm_res_hop_key(struct hlist_node *hnode)
@@ -531,16 +523,6 @@ static void ldlm_res_hop_put(struct cfs_hash *hs, struct hlist_node *hnode)
 	.hs_put		= ldlm_res_hop_put
 };
 
-static struct cfs_hash_ops ldlm_ns_fid_hash_ops = {
-	.hs_hash	= ldlm_res_hop_fid_hash,
-	.hs_key		= ldlm_res_hop_key,
-	.hs_keycmp      = ldlm_res_hop_keycmp,
-	.hs_keycpy      = NULL,
-	.hs_object      = ldlm_res_hop_object,
-	.hs_get		= ldlm_res_hop_get_locked,
-	.hs_put		= ldlm_res_hop_put
-};
-
 struct ldlm_ns_hash_def {
 	enum ldlm_ns_type	nsd_type;
 	/** hash bucket bits */
@@ -556,13 +538,13 @@ struct ldlm_ns_hash_def {
 		.nsd_type       = LDLM_NS_TYPE_MDC,
 		.nsd_bkt_bits   = 11,
 		.nsd_all_bits   = 16,
-		.nsd_hops       = &ldlm_ns_fid_hash_ops,
+		.nsd_hops       = &ldlm_ns_hash_ops,
 	},
 	{
 		.nsd_type       = LDLM_NS_TYPE_MDT,
 		.nsd_bkt_bits   = 14,
 		.nsd_all_bits   = 21,
-		.nsd_hops       = &ldlm_ns_fid_hash_ops,
+		.nsd_hops       = &ldlm_ns_hash_ops,
 	},
 	{
 		.nsd_type       = LDLM_NS_TYPE_OSC,
@@ -578,13 +560,13 @@ struct ldlm_ns_hash_def {
 	},
 	{
 		.nsd_type       = LDLM_NS_TYPE_MGC,
-		.nsd_bkt_bits   = 4,
+		.nsd_bkt_bits   = 3,
 		.nsd_all_bits   = 4,
 		.nsd_hops       = &ldlm_ns_hash_ops,
 	},
 	{
 		.nsd_type       = LDLM_NS_TYPE_MGT,
-		.nsd_bkt_bits   = 4,
+		.nsd_bkt_bits   = 3,
 		.nsd_all_bits   = 4,
 		.nsd_hops       = &ldlm_ns_hash_ops,
 	},
@@ -613,9 +595,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 					  enum ldlm_ns_type ns_type)
 {
 	struct ldlm_namespace *ns = NULL;
-	struct ldlm_ns_bucket *nsb;
 	struct ldlm_ns_hash_def *nsd;
-	struct cfs_hash_bd bd;
 	int idx;
 	int rc;
 
@@ -644,7 +624,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 
 	ns->ns_rs_hash = cfs_hash_create(name,
 					 nsd->nsd_all_bits, nsd->nsd_all_bits,
-					 nsd->nsd_bkt_bits, sizeof(*nsb),
+					 nsd->nsd_bkt_bits, 0,
 					 CFS_HASH_MIN_THETA,
 					 CFS_HASH_MAX_THETA,
 					 nsd->nsd_hops,
@@ -655,8 +635,16 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	if (!ns->ns_rs_hash)
 		goto out_ns;
 
-	cfs_hash_for_each_bucket(ns->ns_rs_hash, &bd, idx) {
-		nsb = cfs_hash_bd_extra_get(ns->ns_rs_hash, &bd);
+	ns->ns_bucket_bits = nsd->nsd_all_bits - nsd->nsd_bkt_bits;
+	ns->ns_rs_buckets = kvmalloc(BIT(ns->ns_bucket_bits) *
+				     sizeof(ns->ns_rs_buckets[0]),
+				     GFP_KERNEL);
+	if (!ns->ns_rs_buckets)
+		goto out_hash;
+
+	for (idx = 0; idx < (1 << ns->ns_bucket_bits); idx++) {
+		struct ldlm_ns_bucket *nsb = &ns->ns_rs_buckets[idx];
+
 		at_init(&nsb->nsb_at_estimate, ldlm_enqueue_min, 0);
 		nsb->nsb_namespace = ns;
 	}
@@ -711,6 +699,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ldlm_namespace_sysfs_unregister(ns);
 	ldlm_namespace_cleanup(ns, 0);
 out_hash:
+	kvfree(ns->ns_rs_buckets);
 	kfree(ns->ns_name);
 	cfs_hash_putref(ns->ns_rs_hash);
 out_ns:
@@ -973,6 +962,7 @@ void ldlm_namespace_free_post(struct ldlm_namespace *ns)
 	ldlm_namespace_debugfs_unregister(ns);
 	ldlm_namespace_sysfs_unregister(ns);
 	cfs_hash_putref(ns->ns_rs_hash);
+	kvfree(ns->ns_rs_buckets);
 	kfree(ns->ns_name);
 	/* Namespace @ns should be not on list at this time, otherwise
 	 * this will cause issues related to using freed @ns in poold
@@ -1087,6 +1077,7 @@ struct ldlm_resource *
 	struct cfs_hash_bd bd;
 	u64 version;
 	int ns_refcount = 0;
+	int hash;
 
 	LASSERT(!parent);
 	LASSERT(ns->ns_rs_hash);
@@ -1111,7 +1102,8 @@ struct ldlm_resource *
 	if (!res)
 		return ERR_PTR(-ENOMEM);
 
-	res->lr_ns_bucket = cfs_hash_bd_extra_get(ns->ns_rs_hash, &bd);
+	hash = ldlm_res_hop_fid_hash(name, ns->ns_bucket_bits);
+	res->lr_ns_bucket = &ns->ns_rs_buckets[hash];
 	res->lr_name = *name;
 	res->lr_type = type;
 
-- 
1.8.3.1
