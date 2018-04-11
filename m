From: NeilBrown <neilb@suse.com>
Date: Thu, 12 Apr 2018 07:54:48 +1000
Subject: [lustre-devel] [PATCH 04/20] staging: lustre: convert osc_quota
 hash to rhashtable
In-Reply-To: <152348312863.12394.11915752362061083241.stgit@noble>
References: <152348312863.12394.11915752362061083241.stgit@noble>
Message-ID: <152348368865.12394.3783473894491587885.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

As this is indexed by an integer, an extensible array
or extensible bitmap would be better.
If/when xarray lands, we should change to use that.

For now, just a simple conversion to rhashtable.

When removing an entry, we need to hold rcu_read_lock()
across the lookup and remove in case we race with another thread
performing a removal.  This means we need to use call_rcu()
to free the quota info so we need an rcu_head in there, which
unfortunately doubles the size of the structure.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd.h      |    2 
 drivers/staging/lustre/lustre/osc/osc_internal.h |    5 -
 drivers/staging/lustre/lustre/osc/osc_quota.c    |  136 +++++++---------------
 3 files changed, 48 insertions(+), 95 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 1818fe6a7a2f..682902e744e2 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -333,7 +333,7 @@ struct client_obd {
 	void		    *cl_writeback_work;
 	void			*cl_lru_work;
 	/* hash tables for osc_quota_info */
-	struct cfs_hash	      *cl_quota_hash[MAXQUOTAS];
+	struct rhashtable	cl_quota_hash[MAXQUOTAS];
 };
 
 #define obd2cli_tgt(obd) ((char *)(obd)->u.cli.cl_target_uuid.uuid)
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index be8c7829b3de..fca020568c19 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -188,8 +188,9 @@ extern struct lu_kmem_descr osc_caches[];
 extern struct kmem_cache *osc_quota_kmem;
 struct osc_quota_info {
 	/** linkage for quota hash table */
-	struct hlist_node oqi_hash;
-	u32	  oqi_id;
+	struct rhash_head oqi_hash;
+	u32		  oqi_id;
+	struct rcu_head	  rcu;
 };
 
 int osc_quota_setup(struct obd_device *obd);
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index ce1731dc604f..723ec2fb18bf 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -27,6 +27,13 @@
 #include <obd_class.h>
 #include "osc_internal.h"
 
+static const struct rhashtable_params quota_hash_params = {
+	.key_len	= sizeof(u32),
+	.key_offset	= offsetof(struct osc_quota_info, oqi_id),
+	.head_offset	= offsetof(struct osc_quota_info, oqi_hash),
+	.automatic_shrinking = true,
+};
+
 static inline struct osc_quota_info *osc_oqi_alloc(u32 id)
 {
 	struct osc_quota_info *oqi;
@@ -45,9 +52,10 @@ int osc_quota_chkdq(struct client_obd *cli, const unsigned int qid[])
 	for (type = 0; type < MAXQUOTAS; type++) {
 		struct osc_quota_info *oqi;
 
-		oqi = cfs_hash_lookup(cli->cl_quota_hash[type], &qid[type]);
+		oqi = rhashtable_lookup_fast(&cli->cl_quota_hash[type], &qid[type],
+					     quota_hash_params);
 		if (oqi) {
-			/* do not try to access oqi here, it could have been
+			/* Must not access oqi here, it could have been
 			 * freed by osc_quota_setdq()
 			 */
 
@@ -63,6 +71,14 @@ int osc_quota_chkdq(struct client_obd *cli, const unsigned int qid[])
 	return QUOTA_OK;
 }
 
+static void osc_quota_free(struct rcu_head *head)
+{
+	struct osc_quota_info *oqi = container_of(head, struct osc_quota_info, rcu);
+
+	kmem_cache_free(osc_quota_kmem, oqi);
+}
+
+
 #define MD_QUOTA_FLAG(type) ((type == USRQUOTA) ? OBD_MD_FLUSRQUOTA \
 						: OBD_MD_FLGRPQUOTA)
 #define FL_QUOTA_FLAG(type) ((type == USRQUOTA) ? OBD_FL_NO_USRQUOTA \
@@ -84,11 +100,14 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 			continue;
 
 		/* lookup the ID in the per-type hash table */
-		oqi = cfs_hash_lookup(cli->cl_quota_hash[type], &qid[type]);
+		rcu_read_lock();
+		oqi = rhashtable_lookup_fast(&cli->cl_quota_hash[type], &qid[type],
+					     quota_hash_params);
 		if ((flags & FL_QUOTA_FLAG(type)) != 0) {
 			/* This ID is getting close to its quota limit, let's
 			 * switch to sync I/O
 			 */
+			rcu_read_unlock();
 			if (oqi)
 				continue;
 
@@ -98,12 +117,16 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 				break;
 			}
 
-			rc = cfs_hash_add_unique(cli->cl_quota_hash[type],
-						 &qid[type], &oqi->oqi_hash);
+			rc = rhashtable_lookup_insert_fast(&cli->cl_quota_hash[type],
+							   &oqi->oqi_hash, quota_hash_params);
 			/* race with others? */
-			if (rc == -EALREADY) {
-				rc = 0;
+			if (rc) {
 				kmem_cache_free(osc_quota_kmem, oqi);
+				if (rc != -EEXIST) {
+					rc = -ENOMEM;
+					break;
+				}
+				rc = 0;
 			}
 
 			CDEBUG(D_QUOTA, "%s: setdq to insert for %s %d (%d)\n",
@@ -114,14 +137,14 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 			/* This ID is now off the hook, let's remove it from
 			 * the hash table
 			 */
-			if (!oqi)
+			if (!oqi) {
+				rcu_read_unlock();
 				continue;
-
-			oqi = cfs_hash_del_key(cli->cl_quota_hash[type],
-					       &qid[type]);
-			if (oqi)
-				kmem_cache_free(osc_quota_kmem, oqi);
-
+			}
+			if (rhashtable_remove_fast(&cli->cl_quota_hash[type],
+						   &oqi->oqi_hash, quota_hash_params) == 0)
+				call_rcu(&oqi->rcu, osc_quota_free);
+			rcu_read_unlock();
 			CDEBUG(D_QUOTA, "%s: setdq to remove for %s %d (%p)\n",
 			       cli_name(cli),
 			       type == USRQUOTA ? "user" : "group",
@@ -132,93 +155,21 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 	return rc;
 }
 
-/*
- * Hash operations for uid/gid <-> osc_quota_info
- */
-static unsigned int
-oqi_hashfn(struct cfs_hash *hs, const void *key, unsigned int mask)
-{
-	return cfs_hash_u32_hash(*((__u32 *)key), mask);
-}
-
-static int
-oqi_keycmp(const void *key, struct hlist_node *hnode)
-{
-	struct osc_quota_info *oqi;
-	u32 uid;
-
-	LASSERT(key);
-	uid = *((u32 *)key);
-	oqi = hlist_entry(hnode, struct osc_quota_info, oqi_hash);
-
-	return uid == oqi->oqi_id;
-}
-
-static void *
-oqi_key(struct hlist_node *hnode)
-{
-	struct osc_quota_info *oqi;
-
-	oqi = hlist_entry(hnode, struct osc_quota_info, oqi_hash);
-	return &oqi->oqi_id;
-}
-
-static void *
-oqi_object(struct hlist_node *hnode)
-{
-	return hlist_entry(hnode, struct osc_quota_info, oqi_hash);
-}
-
-static void
-oqi_get(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-}
-
-static void
-oqi_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-}
-
 static void
-oqi_exit(struct cfs_hash *hs, struct hlist_node *hnode)
+oqi_exit(void *vquota, void *data)
 {
-	struct osc_quota_info *oqi;
-
-	oqi = hlist_entry(hnode, struct osc_quota_info, oqi_hash);
+	struct osc_quota_info *oqi = vquota;
 
-	kmem_cache_free(osc_quota_kmem, oqi);
+	osc_quota_free(&oqi->rcu);
 }
 
-#define HASH_QUOTA_BKT_BITS 5
-#define HASH_QUOTA_CUR_BITS 5
-#define HASH_QUOTA_MAX_BITS 15
-
-static struct cfs_hash_ops quota_hash_ops = {
-	.hs_hash	= oqi_hashfn,
-	.hs_keycmp	= oqi_keycmp,
-	.hs_key		= oqi_key,
-	.hs_object	= oqi_object,
-	.hs_get		= oqi_get,
-	.hs_put_locked	= oqi_put_locked,
-	.hs_exit	= oqi_exit,
-};
-
 int osc_quota_setup(struct obd_device *obd)
 {
 	struct client_obd *cli = &obd->u.cli;
 	int i, type;
 
 	for (type = 0; type < MAXQUOTAS; type++) {
-		cli->cl_quota_hash[type] = cfs_hash_create("QUOTA_HASH",
-							   HASH_QUOTA_CUR_BITS,
-							   HASH_QUOTA_MAX_BITS,
-							   HASH_QUOTA_BKT_BITS,
-							   0,
-							   CFS_HASH_MIN_THETA,
-							   CFS_HASH_MAX_THETA,
-							   &quota_hash_ops,
-							   CFS_HASH_DEFAULT);
-		if (!cli->cl_quota_hash[type])
+		if (rhashtable_init(&cli->cl_quota_hash[type], &quota_hash_params) != 0)
 			break;
 	}
 
@@ -226,7 +177,7 @@ int osc_quota_setup(struct obd_device *obd)
 		return 0;
 
 	for (i = 0; i < type; i++)
-		cfs_hash_putref(cli->cl_quota_hash[i]);
+		rhashtable_destroy(&cli->cl_quota_hash[i]);
 
 	return -ENOMEM;
 }
@@ -237,7 +188,8 @@ int osc_quota_cleanup(struct obd_device *obd)
 	int type;
 
 	for (type = 0; type < MAXQUOTAS; type++)
-		cfs_hash_putref(cli->cl_quota_hash[type]);
+		rhashtable_free_and_destroy(&cli->cl_quota_hash[type],
+					    oqi_exit, NULL);
 
 	return 0;
 }
