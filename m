From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:14 -0500
Subject: [lustre-devel] [PATCH 566/622] lustre: ldlm: add a counter to the
 per-namespace data
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-567-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

When we change the resource hash to rhashtable we won't have
a per-bucket counter.  We could use the nelems global counter,
but ldlm_resource goes to some trouble to avoid having any
table-wide atomics, and hopefully rhashtable will grow the
ability to disable the global counter in the near future.
Having a counter we control makes it easier to manage the
back-reference to the namespace when there is anything in the
hash table.

So add a counter to the ldlm_ns_bucket.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8130
Lustre-commit: f9314d6e9259e6c7 ("LU-8130 ldlm: add a counter to the per-namespace data")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36219
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h |  2 ++
 fs/lustre/ldlm/ldlm_resource.c | 10 +++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index cc4b8b0..9ca79f4 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -306,6 +306,8 @@ struct ldlm_ns_bucket {
 	 * fact the network or overall system load is at fault
 	 */
 	struct adaptive_timeout     nsb_at_estimate;
+	/* counter of entries in this bucket */
+	atomic_t		nsb_count;
 };
 
 enum {
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 65ff32c..d009d5d 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -133,12 +133,11 @@ static ssize_t resource_count_show(struct kobject *kobj, struct attribute *attr,
 	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
 						 ns_kobj);
 	u64 res = 0;
-	struct cfs_hash_bd bd;
 	int i;
 
 	/* result is not strictly consistent */
-	cfs_hash_for_each_bucket(ns->ns_rs_hash, &bd, i)
-		res += cfs_hash_bd_count_get(&bd);
+	for (i = 0; i < (1 << ns->ns_bucket_bits); i++)
+		res += atomic_read(&ns->ns_rs_buckets[i].nsb_count);
 	return sprintf(buf, "%lld\n", res);
 }
 LUSTRE_RO_ATTR(resource_count);
@@ -647,6 +646,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 
 		at_init(&nsb->nsb_at_estimate, ldlm_enqueue_min, 0);
 		nsb->nsb_namespace = ns;
+		atomic_set(&nsb->nsb_count, 0);
 	}
 
 	ns->ns_obd = obd;
@@ -1126,7 +1126,7 @@ struct ldlm_resource *
 	}
 	/* We won! Let's add the resource. */
 	cfs_hash_bd_add_locked(ns->ns_rs_hash, &bd, &res->lr_hash);
-	if (cfs_hash_bd_count_get(&bd) == 1)
+	if (atomic_inc_return(&res->lr_ns_bucket->nsb_count) == 1)
 		ns_refcount = ldlm_namespace_get_return(ns);
 
 	cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
@@ -1170,7 +1170,7 @@ static void __ldlm_resource_putref_final(struct cfs_hash_bd *bd,
 	cfs_hash_bd_unlock(ns->ns_rs_hash, bd, 1);
 	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_free)
 		ns->ns_lvbo->lvbo_free(res);
-	if (cfs_hash_bd_count_get(bd) == 0)
+	if (atomic_dec_and_test(&nsb->nsb_count))
 		ldlm_namespace_put(ns);
 	if (res->lr_itree)
 		kmem_cache_free(ldlm_interval_tree_slab, res->lr_itree);
-- 
1.8.3.1
