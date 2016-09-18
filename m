From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:17 -0400
Subject: [lustre-devel] [PATCH 018/124] staging: lustre: obdclass: fix
	comparison between signed and unsigned
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Make lu_buf->lb_len unsigned.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5417
Reviewed-on: http://review.whamcloud.com/11281
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |    2 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   16 ++++++++--------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index fe40b42..66ab98a 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -1290,7 +1290,7 @@ static inline bool lu_name_is_valid_2(const char *name, size_t name_len)
  */
 struct lu_buf {
 	void   *lb_buf;
-	ssize_t lb_len;
+	size_t	lb_len;
 };
 
 #define DLUBUF "(%p %zu)"
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index b6fd9af..44a854c 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -341,7 +341,7 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 	int		      start;
 	int		      count;
 	int		      bnr;
-	int		      i;
+	unsigned int i;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_OBD_NO_LRU))
 		return 0;
@@ -869,11 +869,11 @@ EXPORT_SYMBOL(lu_site_print);
 /**
  * Return desired hash table order.
  */
-static int lu_htable_order(struct lu_device *top)
+static unsigned int lu_htable_order(struct lu_device *top)
 {
 	unsigned long bits_max = LU_SITE_BITS_MAX;
 	unsigned long cache_size;
-	int bits;
+	unsigned int bits;
 
 	/*
 	 * Calculate hash table size, assuming that we want reasonable
@@ -1325,7 +1325,7 @@ static unsigned key_set_version;
 int lu_context_key_register(struct lu_context_key *key)
 {
 	int result;
-	int i;
+	unsigned int i;
 
 	LASSERT(key->lct_init);
 	LASSERT(key->lct_fini);
@@ -1531,7 +1531,7 @@ EXPORT_SYMBOL(lu_context_key_revive);
 
 static void keys_fini(struct lu_context *ctx)
 {
-	int	i;
+	unsigned int i;
 
 	if (!ctx->lc_value)
 		return;
@@ -1545,7 +1545,7 @@ static void keys_fini(struct lu_context *ctx)
 
 static int keys_fill(struct lu_context *ctx)
 {
-	int i;
+	unsigned int i;
 
 	LINVRNT(ctx->lc_value);
 	for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
@@ -1658,7 +1658,7 @@ EXPORT_SYMBOL(lu_context_enter);
  */
 void lu_context_exit(struct lu_context *ctx)
 {
-	int i;
+	unsigned int i;
 
 	LINVRNT(ctx->lc_state == LCS_ENTERED);
 	ctx->lc_state = LCS_LEFT;
@@ -1740,7 +1740,7 @@ static void lu_site_stats_get(struct cfs_hash *hs,
 			      struct lu_site_stats *stats, int populated)
 {
 	struct cfs_hash_bd bd;
-	int	   i;
+	unsigned int i;
 
 	cfs_hash_for_each_bucket(hs, &bd, i) {
 		struct lu_site_bkt_data *bkt = cfs_hash_bd_extra_get(hs, &bd);
-- 
1.7.1
