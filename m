From: NeilBrown <neilb@suse.com>
Date: Thu, 12 Apr 2018 07:54:49 +1000
Subject: [lustre-devel] [PATCH 17/20] staging: lustre: use call_rcu() to
 free lu_object_headers
In-Reply-To: <152348312863.12394.11915752362061083241.stgit@noble>
References: <152348312863.12394.11915752362061083241.stgit@noble>
Message-ID: <152348368912.12394.12204341677623060724.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Using call_rcu to free lu_object_headers will allow us to use
rhashtable and get lockless lookup.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |    6 +++++-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    9 ++++++++-
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |    9 ++++++++-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    8 +++++++-
 4 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index d23a78577fb5..85066ece44d6 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -535,8 +535,12 @@ struct lu_object_header {
 	struct hlist_node       loh_hash;
 	/**
 	 * Linkage into per-site LRU list. Protected by lu_site::ls_guard.
+	 * memory shared with lru_head for delayed freeing;
 	 */
-	struct list_head	     loh_lru;
+	union {
+		struct list_head	loh_lru;
+		struct rcu_head		loh_rcu;
+	};
 	/**
 	 * Linkage into list of layers. Never modified once set (except lately
 	 * during object destruction). No locking is necessary.
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 05ad3b322a29..48a999f8406b 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -251,13 +251,20 @@ static int vvp_object_init(const struct lu_env *env, struct lu_object *obj,
 	return result;
 }
 
+static void __vvp_object_free(struct rcu_head *rcu)
+{
+	struct vvp_object *vob = container_of(rcu, struct vvp_object, vob_header.coh_lu.loh_rcu);
+
+	kmem_cache_free(vvp_object_kmem, vob);
+}
+
 static void vvp_object_free(const struct lu_env *env, struct lu_object *obj)
 {
 	struct vvp_object *vob = lu2vvp(obj);
 
 	lu_object_fini(obj);
 	lu_object_header_fini(obj->lo_header);
-	kmem_cache_free(vvp_object_kmem, vob);
+	call_rcu(&vob->vob_header.coh_lu.loh_rcu, __vvp_object_free);
 }
 
 static const struct lu_object_operations vvp_lu_obj_ops = {
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index 13d452086b61..3626c2500149 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -70,6 +70,13 @@ int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
 	return result;
 }
 
+static void __lovsub_object_free(struct rcu_head *rcu)
+{
+	struct lovsub_object *los = container_of(rcu, struct lovsub_object,
+						 lso_header.coh_lu.loh_rcu);
+	kmem_cache_free(lovsub_object_kmem, los);
+}
+
 static void lovsub_object_free(const struct lu_env *env, struct lu_object *obj)
 {
 	struct lovsub_object *los = lu2lovsub(obj);
@@ -88,7 +95,7 @@ static void lovsub_object_free(const struct lu_env *env, struct lu_object *obj)
 
 	lu_object_fini(obj);
 	lu_object_header_fini(&los->lso_header.coh_lu);
-	kmem_cache_free(lovsub_object_kmem, los);
+	call_rcu(&los->lso_header.coh_lu.loh_rcu, __lovsub_object_free);
 }
 
 static int lovsub_object_print(const struct lu_env *env, void *cookie,
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 767067b61109..16bf3b5a74e4 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -431,6 +431,12 @@ static int echo_object_init(const struct lu_env *env, struct lu_object *obj,
 	return 0;
 }
 
+static void __echo_object_free(struct rcu_head *rcu)
+{
+	struct echo_object *eco = container_of(rcu, struct echo_object, eo_hdr.coh_lu.loh_rcu);
+	kmem_cache_free(echo_object_kmem, eco);
+}
+
 static void echo_object_free(const struct lu_env *env, struct lu_object *obj)
 {
 	struct echo_object *eco    = cl2echo_obj(lu2cl(obj));
@@ -446,7 +452,7 @@ static void echo_object_free(const struct lu_env *env, struct lu_object *obj)
 	lu_object_header_fini(obj->lo_header);
 
 	kfree(eco->eo_oinfo);
-	kmem_cache_free(echo_object_kmem, eco);
+	call_rcu(&eco->eo_hdr.coh_lu.loh_rcu, __echo_object_free);
 }
 
 static int echo_object_print(const struct lu_env *env, void *cookie,
