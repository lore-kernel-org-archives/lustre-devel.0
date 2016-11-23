From: James Simmons <jsimmons@infradead.org>
Date: Wed, 23 Nov 2016 17:59:48 -0500
Subject: [lustre-devel] [PATCH 2/5] staging: lustre: ldlm: remove
	ldlm_side_t typedef usage from code
In-Reply-To: <1479941991-30059-1-git-send-email-jsimmons@infradead.org>
References: <1479941991-30059-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479941991-30059-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Replace usage of ldlm_side_t with named enums
to conform to upstream coding style.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: http://review.whamcloud.com/15300
Reviewed-on: http://review.whamcloud.com/15301
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   12 ++++++------
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   17 +++++++++--------
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |    9 +++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   14 +++++++-------
 4 files changed, 27 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 02921bf..02c90b0 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -86,10 +86,10 @@ enum ldlm_error {
  * decisions about lack of conflicts or do any autonomous lock granting without
  * first speaking to a server.
  */
-typedef enum {
+enum ldlm_side {
 	LDLM_NAMESPACE_SERVER = 1 << 0,
 	LDLM_NAMESPACE_CLIENT = 1 << 1
-} ldlm_side_t;
+};
 
 /**
  * The blocking callback is overloaded to perform two functions.  These flags
@@ -359,7 +359,7 @@ struct ldlm_namespace {
 	struct obd_device	*ns_obd;
 
 	/** Flag indicating if namespace is on client instead of server */
-	ldlm_side_t		ns_client;
+	enum ldlm_side		ns_client;
 
 	/** Resource hash table for namespace. */
 	struct cfs_hash		*ns_rs_hash;
@@ -1187,7 +1187,7 @@ enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
 /* resource.c */
 struct ldlm_namespace *
 ldlm_namespace_new(struct obd_device *obd, char *name,
-		   ldlm_side_t client, enum ldlm_appetite apt,
+		   enum ldlm_side client, enum ldlm_appetite apt,
 		   enum ldlm_ns_type ns_type);
 int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags);
 void ldlm_namespace_get(struct ldlm_namespace *ns);
@@ -1206,7 +1206,7 @@ void ldlm_resource_add_lock(struct ldlm_resource *res,
 			    struct ldlm_lock *lock);
 void ldlm_resource_unlink_lock(struct ldlm_lock *lock);
 void ldlm_res2desc(struct ldlm_resource *res, struct ldlm_resource_desc *desc);
-void ldlm_dump_all_namespaces(ldlm_side_t client, int level);
+void ldlm_dump_all_namespaces(enum ldlm_side client, int level);
 void ldlm_namespace_dump(int level, struct ldlm_namespace *);
 void ldlm_resource_dump(int level, struct ldlm_resource *);
 int ldlm_lock_change_resource(struct ldlm_namespace *, struct ldlm_lock *,
@@ -1331,7 +1331,7 @@ static inline void check_res_locked(struct ldlm_resource *res)
 void ldlm_pools_fini(void);
 
 int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
-		   int idx, ldlm_side_t client);
+		   int idx, enum ldlm_side client);
 void ldlm_pool_fini(struct ldlm_pool *pl);
 void ldlm_pool_add(struct ldlm_pool *pl, struct ldlm_lock *lock);
 void ldlm_pool_del(struct ldlm_pool *pl, struct ldlm_lock *lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 1a98a31..e2c3c6e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -39,13 +39,13 @@
 extern struct mutex ldlm_cli_namespace_lock;
 extern struct list_head ldlm_cli_active_namespace_list;
 
-static inline int ldlm_namespace_nr_read(ldlm_side_t client)
+static inline int ldlm_namespace_nr_read(enum ldlm_side client)
 {
 	return client == LDLM_NAMESPACE_SERVER ?
 		ldlm_srv_namespace_nr : ldlm_cli_namespace_nr;
 }
 
-static inline void ldlm_namespace_nr_inc(ldlm_side_t client)
+static inline void ldlm_namespace_nr_inc(enum ldlm_side client)
 {
 	if (client == LDLM_NAMESPACE_SERVER)
 		ldlm_srv_namespace_nr++;
@@ -53,7 +53,7 @@ static inline void ldlm_namespace_nr_inc(ldlm_side_t client)
 		ldlm_cli_namespace_nr++;
 }
 
-static inline void ldlm_namespace_nr_dec(ldlm_side_t client)
+static inline void ldlm_namespace_nr_dec(enum ldlm_side client)
 {
 	if (client == LDLM_NAMESPACE_SERVER)
 		ldlm_srv_namespace_nr--;
@@ -61,13 +61,13 @@ static inline void ldlm_namespace_nr_dec(ldlm_side_t client)
 		ldlm_cli_namespace_nr--;
 }
 
-static inline struct list_head *ldlm_namespace_list(ldlm_side_t client)
+static inline struct list_head *ldlm_namespace_list(enum ldlm_side client)
 {
 	return client == LDLM_NAMESPACE_SERVER ?
 		&ldlm_srv_namespace_list : &ldlm_cli_active_namespace_list;
 }
 
-static inline struct mutex *ldlm_namespace_lock(ldlm_side_t client)
+static inline struct mutex *ldlm_namespace_lock(enum ldlm_side client)
 {
 	return client == LDLM_NAMESPACE_SERVER ?
 		&ldlm_srv_namespace_lock : &ldlm_cli_namespace_lock;
@@ -79,10 +79,11 @@ static inline int ldlm_ns_empty(struct ldlm_namespace *ns)
 	return atomic_read(&ns->ns_bref) == 0;
 }
 
-void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *, ldlm_side_t);
+void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *,
+					  enum ldlm_side);
 void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *,
-					    ldlm_side_t);
-struct ldlm_namespace *ldlm_namespace_first_locked(ldlm_side_t);
+					    enum ldlm_side);
+struct ldlm_namespace *ldlm_namespace_first_locked(enum ldlm_side);
 
 /* ldlm_request.c */
 /* Cancel lru flag, it indicates we cancel aged locks. */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index b820309..252bddb 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -651,7 +651,7 @@ static void ldlm_pool_debugfs_fini(struct ldlm_pool *pl)
 }
 
 int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
-		   int idx, ldlm_side_t client)
+		   int idx, enum ldlm_side client)
 {
 	int rc;
 
@@ -788,7 +788,7 @@ static int ldlm_pool_granted(struct ldlm_pool *pl)
  * count locks from all namespaces (if possible). Returns number of
  * cached locks.
  */
-static unsigned long ldlm_pools_count(ldlm_side_t client, gfp_t gfp_mask)
+static unsigned long ldlm_pools_count(enum ldlm_side client, gfp_t gfp_mask)
 {
 	unsigned long total = 0;
 	int nr_ns;
@@ -837,7 +837,8 @@ static unsigned long ldlm_pools_count(ldlm_side_t client, gfp_t gfp_mask)
 	return total;
 }
 
-static unsigned long ldlm_pools_scan(ldlm_side_t client, int nr, gfp_t gfp_mask)
+static unsigned long ldlm_pools_scan(enum ldlm_side client, int nr,
+				     gfp_t gfp_mask)
 {
 	unsigned long freed = 0;
 	int tmp, nr_ns;
@@ -895,7 +896,7 @@ static unsigned long ldlm_pools_cli_scan(struct shrinker *s,
 			       sc->gfp_mask);
 }
 
-static int ldlm_pools_recalc(ldlm_side_t client)
+static int ldlm_pools_recalc(enum ldlm_side client)
 {
 	struct ldlm_namespace *ns;
 	struct ldlm_namespace *ns_old = NULL;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index c452400..ca2cd4a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -612,7 +612,7 @@ struct ldlm_ns_hash_def {
 
 /** Register \a ns in the list of namespaces */
 static void ldlm_namespace_register(struct ldlm_namespace *ns,
-				    ldlm_side_t client)
+				    enum ldlm_side client)
 {
 	mutex_lock(ldlm_namespace_lock(client));
 	LASSERT(list_empty(&ns->ns_list_chain));
@@ -625,7 +625,7 @@ static void ldlm_namespace_register(struct ldlm_namespace *ns,
  * Create and initialize new empty namespace.
  */
 struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
-					  ldlm_side_t client,
+					  enum ldlm_side client,
 					  enum ldlm_appetite apt,
 					  enum ldlm_ns_type ns_type)
 {
@@ -954,7 +954,7 @@ void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
 
 /** Unregister \a ns from the list of namespaces. */
 static void ldlm_namespace_unregister(struct ldlm_namespace *ns,
-				      ldlm_side_t client)
+				      enum ldlm_side client)
 {
 	mutex_lock(ldlm_namespace_lock(client));
 	LASSERT(!list_empty(&ns->ns_list_chain));
@@ -1018,7 +1018,7 @@ void ldlm_namespace_put(struct ldlm_namespace *ns)
 
 /** Should be called with ldlm_namespace_lock(client) taken. */
 void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *ns,
-					  ldlm_side_t client)
+					  enum ldlm_side client)
 {
 	LASSERT(!list_empty(&ns->ns_list_chain));
 	LASSERT(mutex_is_locked(ldlm_namespace_lock(client)));
@@ -1027,7 +1027,7 @@ void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *ns,
 
 /** Should be called with ldlm_namespace_lock(client) taken. */
 void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
-					    ldlm_side_t client)
+					    enum ldlm_side client)
 {
 	LASSERT(!list_empty(&ns->ns_list_chain));
 	LASSERT(mutex_is_locked(ldlm_namespace_lock(client)));
@@ -1035,7 +1035,7 @@ void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
 }
 
 /** Should be called with ldlm_namespace_lock(client) taken. */
-struct ldlm_namespace *ldlm_namespace_first_locked(ldlm_side_t client)
+struct ldlm_namespace *ldlm_namespace_first_locked(enum ldlm_side client)
 {
 	LASSERT(mutex_is_locked(ldlm_namespace_lock(client)));
 	LASSERT(!list_empty(ldlm_namespace_list(client)));
@@ -1305,7 +1305,7 @@ void ldlm_res2desc(struct ldlm_resource *res, struct ldlm_resource_desc *desc)
  * Print information about all locks in all namespaces on this node to debug
  * log.
  */
-void ldlm_dump_all_namespaces(ldlm_side_t client, int level)
+void ldlm_dump_all_namespaces(enum ldlm_side client, int level)
 {
 	struct list_head *tmp;
 
-- 
1.7.1
