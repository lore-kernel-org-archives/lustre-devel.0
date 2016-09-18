From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:20 -0400
Subject: [lustre-devel] [PATCH 081/124] staging: lustre: obdclass:
	lu_htable_order() return type to long
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-82-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change the type accordant usage.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/12385
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 4395117..7339c8b 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -352,7 +352,7 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 	 * the dispose list, removing them from LRU and hash table.
 	 */
 	start = s->ls_purge_start;
-	bnr = (nr == ~0) ? -1 : nr / CFS_HASH_NBKT(s->ls_obj_hash) + 1;
+	bnr = (nr == ~0) ? -1 : nr / (int)CFS_HASH_NBKT(s->ls_obj_hash) + 1;
  again:
 	/*
 	 * It doesn't make any sense to make purge threads parallel, that can
@@ -869,11 +869,11 @@ EXPORT_SYMBOL(lu_site_print);
 /**
  * Return desired hash table order.
  */
-static unsigned int lu_htable_order(struct lu_device *top)
+static unsigned long lu_htable_order(struct lu_device *top)
 {
 	unsigned long bits_max = LU_SITE_BITS_MAX;
 	unsigned long cache_size;
-	unsigned int bits;
+	unsigned long bits;
 
 	/*
 	 * Calculate hash table size, assuming that we want reasonable
@@ -990,7 +990,7 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 
 	memset(s, 0, sizeof(*s));
 	mutex_init(&s->ls_purge_mutex);
-	snprintf(name, 16, "lu_site_%s", top->ld_type->ldt_name);
+	snprintf(name, sizeof(name), "lu_site_%s", top->ld_type->ldt_name);
 	for (bits = lu_htable_order(top); bits >= LU_SITE_BITS_MIN; bits--) {
 		s->ls_obj_hash = cfs_hash_create(name, bits, bits,
 						 bits - LU_SITE_BKT_BITS,
-- 
1.7.1
