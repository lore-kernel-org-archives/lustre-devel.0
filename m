From: NeilBrown <neilb@suse.com>
Date: Wed, 06 Jun 2018 16:05:19 +1000
Subject: [lustre-devel] [PATCH 03/11] staging: lustre: move interval_insert
 call from ldlm_lock to ldlm_extent
In-Reply-To: <152826510267.16761.14361003167157833896.stgit@noble>
References: <152826510267.16761.14361003167157833896.stgit@noble>
Message-ID: <152826511899.16761.11963878471070889487.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Moving this call results in all interval-tree handling code
being in the one file.  This will simplify conversion to
use Linux interval trees.

The addition of 'struct cb' is a little ugly, but will be gone
is a subsequent patch.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |   27 ++++++++++++++++++++
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    4 +++
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   17 +++----------
 3 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 2f4c305bb340..eb1a9077a514 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -192,3 +192,30 @@ void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 	wpolicy->l_extent.end = lpolicy->l_extent.end;
 	wpolicy->l_extent.gid = lpolicy->l_extent.gid;
 }
+
+struct cb {
+	void *arg;
+	bool (*found)(struct ldlm_lock *lock, void *arg);
+};
+
+static enum interval_iter itree_overlap_cb(struct interval_node *in, void *arg)
+{
+	struct cb *cb = arg;
+	struct ldlm_lock *lock = container_of(in, struct ldlm_lock,
+					      l_tree_node);
+
+	return cb->found(lock, cb->arg) ?
+		INTERVAL_ITER_STOP : INTERVAL_ITER_CONT;
+}
+
+void ldlm_extent_search(struct interval_node *root,
+			struct interval_node_extent *ext,
+			bool (*matches)(struct ldlm_lock *lock, void *data),
+			void *data)
+{
+	struct cb cb = {
+		.arg = data,
+		.found = matches,
+	};
+	interval_search(root, ext, itree_overlap_cb, &cb);
+}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 159de8a59cbb..756fa3d9db3c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -169,6 +169,10 @@ extern struct kmem_cache *ldlm_lock_slab;
 /* ldlm_extent.c */
 void ldlm_extent_add_lock(struct ldlm_resource *res, struct ldlm_lock *lock);
 void ldlm_extent_unlink_lock(struct ldlm_lock *lock);
+void ldlm_extent_search(struct interval_node *root,
+			struct interval_node_extent *ext,
+			bool (*matches)(struct ldlm_lock *lock, void *data),
+			void *data);
 
 /* l_lock.c */
 void l_check_ns_lock(struct ldlm_namespace *ns);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 034935e06393..4213fe047073 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1053,8 +1053,9 @@ struct lock_match_data {
  * \param lock	test-against this lock
  * \param data	parameters
  */
-static bool lock_matches(struct ldlm_lock *lock, struct lock_match_data *data)
+static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 {
+	struct lock_match_data *data = vdata;
 	union ldlm_policy_data *lpol = &lock->l_policy_data;
 	enum ldlm_mode match;
 
@@ -1135,16 +1136,6 @@ static bool lock_matches(struct ldlm_lock *lock, struct lock_match_data *data)
 	return true;
 }
 
-static enum interval_iter itree_overlap_cb(struct interval_node *in, void *args)
-{
-	struct lock_match_data *data = args;
-	struct ldlm_lock *lock = container_of(in, struct ldlm_lock,
-					      l_tree_node);
-
-	return lock_matches(lock, data) ?
-		INTERVAL_ITER_STOP : INTERVAL_ITER_CONT;
-}
-
 /**
  * Search for a lock with given parameters in interval trees.
  *
@@ -1171,8 +1162,8 @@ static struct ldlm_lock *search_itree(struct ldlm_resource *res,
 		if (!(tree->lit_mode & *data->lmd_mode))
 			continue;
 
-		interval_search(tree->lit_root, &ext,
-				itree_overlap_cb, data);
+		ldlm_extent_search(tree->lit_root, &ext,
+				   lock_matches, data);
 	}
 	return data->lmd_lock;
 }
