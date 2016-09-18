From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:39 -0400
Subject: [lustre-devel] [PATCH 040/124] staging: lustre: obd: rename
	LUSTRE_STRIPE_MAXBYTES
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-41-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Rename LUSTRE_STRIPE_MAXBYTES to LUSTRE_EXT3_STRIPE_MAXBYTES and
correct the comment describing its use.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/11800
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |    8 +++++---
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    6 +++---
 drivers/staging/lustre/lustre/lov/lov_pack.c       |    2 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 5 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 0917aaa..19230a9 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -73,10 +73,12 @@ static inline void loi_init(struct lov_oinfo *loi)
 {
 }
 
-/* Until such time as we get_info the per-stripe maximum from the OST,
- * we define this to be 2T - 4k, which is the ext3 maxbytes.
+/*
+ * If we are unable to get the maximum object size from the OST in
+ * ocd_maxbytes using OBD_CONNECT_MAXBYTES, then we fall back to using
+ * the old maximum object size from ext3.
  */
-#define LUSTRE_STRIPE_MAXBYTES 0x1fffffff000ULL
+#define LUSTRE_EXT3_STRIPE_MAXBYTES 0x1fffffff000ULL
 
 struct lov_stripe_md {
 	atomic_t     lsm_refc;
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index d88b81d..9f0b5b7 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -154,14 +154,14 @@ static int lsm_destroy_plain(struct lov_stripe_md *lsm, struct obdo *oa,
 }
 
 /* Find minimum stripe maxbytes value.  For inactive or
- * reconnecting targets use LUSTRE_STRIPE_MAXBYTES.
+ * reconnecting targets use LUSTRE_EXT3_STRIPE_MAXBYTES.
  */
 static void lov_tgt_maxbytes(struct lov_tgt_desc *tgt, __u64 *stripe_maxbytes)
 {
 	struct obd_import *imp = tgt->ltd_obd->u.cli.cl_import;
 
 	if (!imp || !tgt->ltd_active) {
-		*stripe_maxbytes = LUSTRE_STRIPE_MAXBYTES;
+		*stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
 		return;
 	}
 
@@ -172,7 +172,7 @@ static void lov_tgt_maxbytes(struct lov_tgt_desc *tgt, __u64 *stripe_maxbytes)
 		if (*stripe_maxbytes > imp->imp_connect_data.ocd_maxbytes)
 			*stripe_maxbytes = imp->imp_connect_data.ocd_maxbytes;
 	} else {
-		*stripe_maxbytes = LUSTRE_STRIPE_MAXBYTES;
+		*stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
 	}
 	spin_unlock(&imp->imp_lock);
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 869ef41..c654810 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -284,7 +284,7 @@ int lov_alloc_memmd(struct lov_stripe_md **lsmp, __u16 stripe_count,
 	spin_lock_init(&(*lsmp)->lsm_lock);
 	(*lsmp)->lsm_magic = magic;
 	(*lsmp)->lsm_stripe_count = stripe_count;
-	(*lsmp)->lsm_maxbytes = LUSTRE_STRIPE_MAXBYTES * stripe_count;
+	(*lsmp)->lsm_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES * stripe_count;
 	(*lsmp)->lsm_pattern = pattern;
 	(*lsmp)->lsm_pool_name[0] = '\0';
 	(*lsmp)->lsm_layout_gen = 0;
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 6968953..cddc2d2 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -454,7 +454,7 @@ static int echo_alloc_memmd(struct echo_device *ed,
 	}
 
 	loi_init((*lsmp)->lsm_oinfo[0]);
-	(*lsmp)->lsm_maxbytes = LUSTRE_STRIPE_MAXBYTES;
+	(*lsmp)->lsm_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
 	ostid_set_seq_echo(&(*lsmp)->lsm_oi);
 
 	return lsm_size;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index d5d2963..7f7c318 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -190,7 +190,7 @@ static int osc_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 	    (imp->imp_connect_data.ocd_connect_flags & OBD_CONNECT_MAXBYTES))
 		(*lsmp)->lsm_maxbytes = imp->imp_connect_data.ocd_maxbytes;
 	else
-		(*lsmp)->lsm_maxbytes = LUSTRE_STRIPE_MAXBYTES;
+		(*lsmp)->lsm_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
 
 	return lsm_size;
 }
-- 
1.7.1
