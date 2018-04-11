From: NeilBrown <neilb@suse.com>
Date: Thu, 12 Apr 2018 07:54:48 +1000
Subject: [lustre-devel] [PATCH 07/20] staging: lustre: ldlm: store name
 directly in namespace.
In-Reply-To: <152348312863.12394.11915752362061083241.stgit@noble>
References: <152348312863.12394.11915752362061083241.stgit@noble>
Message-ID: <152348368875.12394.18428069846372860341.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Rather than storing the name of a namespace in the
hash table, store it directly in the namespace.
This will allow the hashtable to be changed to use
rhashtable.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    5 ++++-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    5 +++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index ab90abe1c2d8..500dda854564 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -364,6 +364,9 @@ struct ldlm_namespace {
 	/** Flag indicating if namespace is on client instead of server */
 	enum ldlm_side		ns_client;
 
+	/** name of this namespace */
+	char			*ns_name;
+
 	/** Resource hash table for namespace. */
 	struct cfs_hash		*ns_rs_hash;
 	struct ldlm_ns_bucket	*ns_rs_buckets;
@@ -882,7 +885,7 @@ static inline bool ldlm_has_layout(struct ldlm_lock *lock)
 static inline char *
 ldlm_ns_name(struct ldlm_namespace *ns)
 {
-	return ns->ns_rs_hash->hs_name;
+	return ns->ns_name;
 }
 
 static inline struct ldlm_namespace *
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 669556420bdf..a14cc12303ab 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -673,6 +673,9 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ns->ns_obd      = obd;
 	ns->ns_appetite = apt;
 	ns->ns_client   = client;
+	ns->ns_name     = kstrdup(name, GFP_KERNEL);
+	if (!ns->ns_name)
+		goto out_hash;
 
 	INIT_LIST_HEAD(&ns->ns_list_chain);
 	INIT_LIST_HEAD(&ns->ns_unused_list);
@@ -715,6 +718,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ldlm_namespace_sysfs_unregister(ns);
 	ldlm_namespace_cleanup(ns, 0);
 out_hash:
+	kfree(ns->ns_name);
 	kvfree(ns->ns_rs_buckets);
 	cfs_hash_putref(ns->ns_rs_hash);
 out_ns:
@@ -980,6 +984,7 @@ void ldlm_namespace_free_post(struct ldlm_namespace *ns)
 	ldlm_namespace_sysfs_unregister(ns);
 	cfs_hash_putref(ns->ns_rs_hash);
 	kvfree(ns->ns_rs_buckets);
+	kfree(ns->ns_name);
 	/* Namespace \a ns should be not on list at this time, otherwise
 	 * this will cause issues related to using freed \a ns in poold
 	 * thread.
