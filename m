From: James Simmons <jsimmons@infradead.org>
Date: Thu,  9 Jun 2016 18:45:46 -0400
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: lnet: Allocate MEs and
	small MDs in own kmem_caches
In-Reply-To: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
References: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1465512347-11650-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruno Faccini <bruno.faccini@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bruno Faccini <bruno.faccini@intel.com>

As part of LU-3848 and LU-4330, it has been discovered that LNET
MEs and small MDs (<=128 Bytes) are allocated in <size-128> kmem_cache
and thus can suffer quite frequent corruptions, from other modules or
Kernel parts, that occur there. To avoid this, MEs and small-MDs
specific kmem_cache have been created.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4430
Reviewed-on: http://review.whamcloud.com/18586
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   36 ++++++++++++++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   45 ++++++++++++++++++++
 2 files changed, 77 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 513a822..51ad729 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -178,6 +178,11 @@ lnet_net_lock_current(void)
 
 #define MAX_PORTALS		64
 
+#define LNET_SMALL_MD_SIZE	offsetof(lnet_libmd_t, md_iov.iov[1])
+extern struct kmem_cache *lnet_mes_cachep;	/* MEs kmem_cache */
+extern struct kmem_cache *lnet_small_mds_cachep;/* <= LNET_SMALL_MD_SIZE bytes
+						 * MDs kmem_cache
+						 */
 static inline lnet_eq_t *
 lnet_eq_alloc(void)
 {
@@ -208,7 +213,19 @@ lnet_md_alloc(lnet_md_t *umd)
 		size = offsetof(lnet_libmd_t, md_iov.iov[niov]);
 	}
 
-	LIBCFS_ALLOC(md, size);
+	if (size <= LNET_SMALL_MD_SIZE) {
+		md = kmem_cache_alloc(lnet_small_mds_cachep,
+				      GFP_NOFS | __GFP_ZERO);
+		if (md) {
+			CDEBUG(D_MALLOC, "slab-alloced 'md' of size %u@%p.\n",
+			       size, md);
+		} else {
+			CDEBUG(D_MALLOC, "failed to allocate 'md' of size %u\n",
+			       size);
+		}
+	} else {
+		LIBCFS_ALLOC(md, size);
+	}
 
 	if (md) {
 		/* Set here in case of early free */
@@ -230,7 +247,12 @@ lnet_md_free(lnet_libmd_t *md)
 	else
 		size = offsetof(lnet_libmd_t, md_iov.iov[md->md_niov]);
 
-	LIBCFS_FREE(md, size);
+	if (size <= LNET_SMALL_MD_SIZE) {
+		CDEBUG(D_MALLOC, "slab-freed 'md' at %p.\n", md);
+		kmem_cache_free(lnet_small_mds_cachep, md);
+	} else {
+		LIBCFS_FREE(md, size);
+	}
 }
 
 static inline lnet_me_t *
@@ -238,14 +260,20 @@ lnet_me_alloc(void)
 {
 	lnet_me_t *me;
 
-	LIBCFS_ALLOC(me, sizeof(*me));
+	me = kmem_cache_alloc(lnet_mes_cachep, GFP_NOFS | __GFP_ZERO);
+	if (me)
+		CDEBUG(D_MALLOC, "slab-alloced 'me' at %p.\n", me);
+	else
+		CDEBUG(D_MALLOC, "failed to allocate 'me'\n");
+
 	return me;
 }
 
 static inline void
 lnet_me_free(lnet_me_t *me)
 {
-	LIBCFS_FREE(me, sizeof(*me));
+	CDEBUG(D_MALLOC, "slab-freed 'me'@%p.\n", me);
+	kmem_cache_free(lnet_mes_cachep, me);
 }
 
 static inline lnet_msg_t *
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index fe0dbe7..9db0ff1 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -103,6 +103,46 @@ lnet_init_locks(void)
 	mutex_init(&the_lnet.ln_api_mutex);
 }
 
+struct kmem_cache *lnet_mes_cachep;		/* MEs kmem_cache */
+struct kmem_cache *lnet_small_mds_cachep;	/* <= LNET_SMALL_MD_SIZE bytes
+						 *  MDs kmem_cache
+						 */
+static int
+lnet_descriptor_setup(void)
+{
+	/*
+	 * create specific kmem_cache for MEs and small MDs (i.e., originally
+	 * allocated in <size-xxx> kmem_cache).
+	 */
+	lnet_mes_cachep = kmem_cache_create("lnet_MEs", sizeof(lnet_me_t),
+					    0, 0, NULL);
+	if (!lnet_mes_cachep)
+		return -ENOMEM;
+
+	lnet_small_mds_cachep = kmem_cache_create("lnet_small_MDs",
+						  LNET_SMALL_MD_SIZE, 0, 0,
+						  NULL);
+	if (!lnet_small_mds_cachep)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void
+lnet_descriptor_cleanup(void)
+{
+
+	if (lnet_small_mds_cachep) {
+		kmem_cache_destroy(lnet_small_mds_cachep);
+		lnet_small_mds_cachep = NULL;
+	}
+
+	if (lnet_mes_cachep) {
+		kmem_cache_destroy(lnet_mes_cachep);
+		lnet_mes_cachep = NULL;
+	}
+}
+
 static int
 lnet_create_remote_nets_table(void)
 {
@@ -553,6 +593,10 @@ lnet_prepare(lnet_pid_t requested_pid)
 	INIT_LIST_HEAD(&the_lnet.ln_drop_rules);
 	INIT_LIST_HEAD(&the_lnet.ln_delay_rules);
 
+	rc = lnet_descriptor_setup();
+	if (rc)
+		goto failed;
+
 	rc = lnet_create_remote_nets_table();
 	if (rc)
 		goto failed;
@@ -652,6 +696,7 @@ lnet_unprepare(void)
 		the_lnet.ln_counters = NULL;
 	}
 	lnet_destroy_remote_nets_table();
+	lnet_descriptor_cleanup();
 
 	return 0;
 }
-- 
1.7.1
