From: NeilBrown <neilb@suse.com>
Date: Tue, 09 Jan 2018 12:19:38 +1100
Subject: [lustre-devel] [PATCH 05/14] staging: lustre: change some
 LIBCFS_ALLOC calls to k?alloc(GFP_KERNEL)
In-Reply-To: <151546052331.9776.7408338350463291753.stgit@noble>
References: <151546052331.9776.7408338350463291753.stgit@noble>
Message-ID: <151546077832.9776.10331372787316896708.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

When an allocation happens from process context rather than
filesystem context, it is best to use GFP_KERNEL rather than
LIBCFS_ALLOC() which always uses GFP_NOFS.
This include initialization during, or prior to, mount,
and code run from separate worker threads.

So for some of these cases, switch to kmalloc, kvmalloc, or
kvmalloc_array() as appropriate.
In some cases we preserve __GFP_ZERO (via kzalloc/kvzalloc), but in
others it is clear that allocated memory is immediately initialized.

In each case, the matching LIBCFS_FREE() is converted to
kfree() or kvfree()

This is just a subset of locations that need changing.
As there are quite a lot, I've broken them up into several
ad-hoc sets to avoid review-fatigue.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_string.h    |    4 ++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   11 ++++------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   22 ++++++++------------
 drivers/staging/lustre/lnet/libcfs/hash.c          |   18 +++++++---------
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c    |    9 ++++----
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |    2 +-
 drivers/staging/lustre/lnet/lnet/config.c          |    2 +-
 7 files changed, 29 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index bb95eaf9f3d5..66463477074a 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -85,11 +85,11 @@ static inline void
 cfs_expr_list_values_free(u32 *values, int num)
 {
 	/*
-	 * This array is allocated by LIBCFS_ALLOC(), so it shouldn't be freed
+	 * This array is allocated by kvalloc(), so it shouldn't be freed
 	 * by OBD_FREE() if it's called by module other than libcfs & LNet,
 	 * otherwise we will see fake memory leak
 	 */
-	LIBCFS_FREE(values, num * sizeof(values[0]));
+	kvfree(values);
 }
 
 void cfs_expr_list_free(struct cfs_expr_list *expr_list);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 9fbf8a044962..bb7b19473e3a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2576,11 +2576,7 @@ static void kiblnd_base_shutdown(void)
 		break;
 	}
 
-	if (kiblnd_data.kib_peers) {
-		LIBCFS_FREE(kiblnd_data.kib_peers,
-			    sizeof(struct list_head) *
-			    kiblnd_data.kib_peer_hash_size);
-	}
+	kvfree(kiblnd_data.kib_peers);
 
 	if (kiblnd_data.kib_scheds)
 		cfs_percpt_free(kiblnd_data.kib_scheds);
@@ -2672,8 +2668,9 @@ static int kiblnd_base_startup(void)
 	INIT_LIST_HEAD(&kiblnd_data.kib_failed_devs);
 
 	kiblnd_data.kib_peer_hash_size = IBLND_PEER_HASH_SIZE;
-	LIBCFS_ALLOC(kiblnd_data.kib_peers,
-		     sizeof(struct list_head) * kiblnd_data.kib_peer_hash_size);
+	kiblnd_data.kib_peers = kvmalloc_array(kiblnd_data.kib_peer_hash_size,
+					       sizeof(struct list_head),
+					       GFP_KERNEL);
 	if (!kiblnd_data.kib_peers)
 		goto failed;
 	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++)
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 51157ae14a9e..dc63ed2ceb97 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -1070,8 +1070,9 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 	conn->ksnc_tx_carrier = NULL;
 	atomic_set(&conn->ksnc_tx_nob, 0);
 
-	LIBCFS_ALLOC(hello, offsetof(struct ksock_hello_msg,
-				     kshm_ips[LNET_MAX_INTERFACES]));
+	hello = kvzalloc(offsetof(struct ksock_hello_msg,
+				  kshm_ips[LNET_MAX_INTERFACES]),
+			 GFP_KERNEL);
 	if (!hello) {
 		rc = -ENOMEM;
 		goto failed_1;
@@ -1334,8 +1335,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 		rc = ksocknal_send_hello(ni, conn, peerid.nid, hello);
 	}
 
-	LIBCFS_FREE(hello, offsetof(struct ksock_hello_msg,
-				    kshm_ips[LNET_MAX_INTERFACES]));
+	kvfree(hello);
 
 	/*
 	 * setup the socket AFTER I've received hello (it disables
@@ -1415,9 +1415,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 	ksocknal_peer_decref(peer);
 
 failed_1:
-	if (hello)
-		LIBCFS_FREE(hello, offsetof(struct ksock_hello_msg,
-					    kshm_ips[LNET_MAX_INTERFACES]));
+	kvfree(hello);
 
 	kfree(conn);
 
@@ -2269,9 +2267,7 @@ ksocknal_free_buffers(void)
 		cfs_percpt_free(ksocknal_data.ksnd_sched_info);
 	}
 
-	LIBCFS_FREE(ksocknal_data.ksnd_peers,
-		    sizeof(struct list_head) *
-		    ksocknal_data.ksnd_peer_hash_size);
+	kvfree(ksocknal_data.ksnd_peers);
 
 	spin_lock(&ksocknal_data.ksnd_tx_lock);
 
@@ -2401,9 +2397,9 @@ ksocknal_base_startup(void)
 	memset(&ksocknal_data, 0, sizeof(ksocknal_data)); /* zero pointers */
 
 	ksocknal_data.ksnd_peer_hash_size = SOCKNAL_PEER_HASH_SIZE;
-	LIBCFS_ALLOC(ksocknal_data.ksnd_peers,
-		     sizeof(struct list_head) *
-		     ksocknal_data.ksnd_peer_hash_size);
+	ksocknal_data.ksnd_peers = kvmalloc_array(ksocknal_data.ksnd_peer_hash_size,
+						  sizeof(struct list_head),
+						  GFP_KERNEL);
 	if (!ksocknal_data.ksnd_peers)
 		return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 4d16147602a6..f7b3c9306456 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -864,12 +864,10 @@ cfs_hash_buckets_free(struct cfs_hash_bucket **buckets,
 {
 	int i;
 
-	for (i = prev_size; i < size; i++) {
-		if (buckets[i])
-			LIBCFS_FREE(buckets[i], bkt_size);
-	}
+	for (i = prev_size; i < size; i++)
+		kfree(buckets[i]);
 
-	LIBCFS_FREE(buckets, sizeof(buckets[0]) * size);
+	kvfree(buckets);
 }
 
 /*
@@ -889,7 +887,7 @@ cfs_hash_buckets_realloc(struct cfs_hash *hs, struct cfs_hash_bucket **old_bkts,
 	if (old_bkts && old_size == new_size)
 		return old_bkts;
 
-	LIBCFS_ALLOC(new_bkts, sizeof(new_bkts[0]) * new_size);
+	new_bkts = kvmalloc_array(new_size, sizeof(new_bkts[0]), GFP_KERNEL);
 	if (!new_bkts)
 		return NULL;
 
@@ -902,7 +900,7 @@ cfs_hash_buckets_realloc(struct cfs_hash *hs, struct cfs_hash_bucket **old_bkts,
 		struct hlist_head *hhead;
 		struct cfs_hash_bd bd;
 
-		LIBCFS_ALLOC(new_bkts[i], cfs_hash_bkt_size(hs));
+		new_bkts[i] = kzalloc(cfs_hash_bkt_size(hs), GFP_KERNEL);
 		if (!new_bkts[i]) {
 			cfs_hash_buckets_free(new_bkts, cfs_hash_bkt_size(hs),
 					      old_size, new_size);
@@ -1014,7 +1012,7 @@ cfs_hash_create(char *name, unsigned int cur_bits, unsigned int max_bits,
 
 	len = !(flags & CFS_HASH_BIGNAME) ?
 	      CFS_HASH_NAME_LEN : CFS_HASH_BIGNAME_LEN;
-	LIBCFS_ALLOC(hs, offsetof(struct cfs_hash, hs_name[len]));
+	hs = kzalloc(offsetof(struct cfs_hash, hs_name[len]), GFP_KERNEL);
 	if (!hs)
 		return NULL;
 
@@ -1046,7 +1044,7 @@ cfs_hash_create(char *name, unsigned int cur_bits, unsigned int max_bits,
 	if (hs->hs_buckets)
 		return hs;
 
-	LIBCFS_FREE(hs, offsetof(struct cfs_hash, hs_name[len]));
+	kfree(hs);
 	return NULL;
 }
 EXPORT_SYMBOL(cfs_hash_create);
@@ -1109,7 +1107,7 @@ cfs_hash_destroy(struct cfs_hash *hs)
 			      0, CFS_HASH_NBKT(hs));
 	i = cfs_hash_with_bigname(hs) ?
 	    CFS_HASH_BIGNAME_LEN : CFS_HASH_NAME_LEN;
-	LIBCFS_FREE(hs, offsetof(struct cfs_hash, hs_name[i]));
+	kfree(hs);
 }
 
 struct cfs_hash *cfs_hash_getref(struct cfs_hash *hs)
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
index df93d8f77ea2..23734cfb5d44 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
@@ -130,10 +130,9 @@ cfs_array_free(void *vars)
 		if (!arr->va_ptrs[i])
 			continue;
 
-		LIBCFS_FREE(arr->va_ptrs[i], arr->va_size);
+		kvfree(arr->va_ptrs[i]);
 	}
-	LIBCFS_FREE(arr, offsetof(struct cfs_var_array,
-				  va_ptrs[arr->va_count]));
+	kvfree(arr);
 }
 EXPORT_SYMBOL(cfs_array_free);
 
@@ -148,7 +147,7 @@ cfs_array_alloc(int count, unsigned int size)
 	struct cfs_var_array *arr;
 	int i;
 
-	LIBCFS_ALLOC(arr, offsetof(struct cfs_var_array, va_ptrs[count]));
+	arr = kvmalloc(offsetof(struct cfs_var_array, va_ptrs[count]), GFP_KERNEL);
 	if (!arr)
 		return NULL;
 
@@ -156,7 +155,7 @@ cfs_array_alloc(int count, unsigned int size)
 	arr->va_size = size;
 
 	for (i = 0; i < count; i++) {
-		LIBCFS_ALLOC(arr->va_ptrs[i], size);
+		arr->va_ptrs[i] = kvzalloc(size, GFP_KERNEL);
 
 		if (!arr->va_ptrs[i]) {
 			cfs_array_free((void *)&arr->va_ptrs[0]);
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index b8d1ce831ff1..442889a3d729 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -437,7 +437,7 @@ cfs_expr_list_values(struct cfs_expr_list *expr_list, int max, u32 **valpp)
 		return -EINVAL;
 	}
 
-	LIBCFS_ALLOC(val, sizeof(val[0]) * count);
+	val = kvmalloc_array(count, sizeof(val[0]), GFP_KERNEL | __GFP_ZERO);
 	if (!val)
 		return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index a1a3c35ea4dc..4b24842e9b16 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -169,7 +169,7 @@ lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
 
 		LASSERT(rc <= LNET_CPT_NUMBER);
 		if (rc == LNET_CPT_NUMBER) {
-			LIBCFS_FREE(ni->ni_cpts, rc * sizeof(ni->ni_cpts[0]));
+			cfs_expr_list_values_free(ni->ni_cpts, LNET_CPT_NUMBER);
 			ni->ni_cpts = NULL;
 		}
 
