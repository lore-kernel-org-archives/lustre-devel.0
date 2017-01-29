From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:51 -0500
Subject: [lustre-devel] [PATCH 23/60] staging: lustre: lmv: remove unused
	placement parameter
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: "John L. Hammond" <john.hammond@intel.com>

Remove the unused lmv.*.placement parameter along with supporting
functions and struct members.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7674
Reviewed-on: http://review.whamcloud.com/18019
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h   |  8 ----
 drivers/staging/lustre/lustre/lmv/lmv_obd.c   |  1 -
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c | 68 ---------------------------
 3 files changed, 77 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 6d3bd05..5c217c0 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -403,18 +403,10 @@ struct lmv_tgt_desc {
 	unsigned long		ltd_active:1; /* target up for requests */
 };
 
-enum placement_policy {
-	PLACEMENT_CHAR_POLICY   = 0,
-	PLACEMENT_NID_POLICY    = 1,
-	PLACEMENT_INVAL_POLICY  = 2,
-	PLACEMENT_MAX_POLICY
-};
-
 struct lmv_obd {
 	int			refcount;
 	struct lu_client_fld	lmv_fld;
 	spinlock_t		lmv_lock;
-	enum placement_policy	lmv_placement;
 	struct lmv_desc		desc;
 	struct obd_uuid		cluuid;
 	struct obd_export	*exp;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 915415c..5926461 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1284,7 +1284,6 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	lmv->desc.ld_active_tgt_count = 0;
 	lmv->max_def_easize = 0;
 	lmv->max_easize = 0;
-	lmv->lmv_placement = PLACEMENT_CHAR_POLICY;
 
 	spin_lock_init(&lmv->lmv_lock);
 	mutex_init(&lmv->lmv_init_mutex);
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index 14fbc9c..ff45802 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -50,73 +50,6 @@ static ssize_t numobd_show(struct kobject *kobj, struct attribute *attr,
 }
 LUSTRE_RO_ATTR(numobd);
 
-static const char *placement_name[] = {
-	[PLACEMENT_CHAR_POLICY] = "CHAR",
-	[PLACEMENT_NID_POLICY]  = "NID",
-	[PLACEMENT_INVAL_POLICY]  = "INVAL"
-};
-
-static enum placement_policy placement_name2policy(char *name, int len)
-{
-	int		     i;
-
-	for (i = 0; i < PLACEMENT_MAX_POLICY; i++) {
-		if (!strncmp(placement_name[i], name, len))
-			return i;
-	}
-	return PLACEMENT_INVAL_POLICY;
-}
-
-static const char *placement_policy2name(enum placement_policy placement)
-{
-	LASSERT(placement < PLACEMENT_MAX_POLICY);
-	return placement_name[placement];
-}
-
-static ssize_t placement_show(struct kobject *kobj, struct attribute *attr,
-			      char *buf)
-{
-	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
-	struct lmv_obd *lmv;
-
-	lmv = &dev->u.lmv;
-	return sprintf(buf, "%s\n", placement_policy2name(lmv->lmv_placement));
-}
-
-#define MAX_POLICY_STRING_SIZE 64
-
-static ssize_t placement_store(struct kobject *kobj, struct attribute *attr,
-			       const char *buffer,
-			       size_t count)
-{
-	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
-	char dummy[MAX_POLICY_STRING_SIZE + 1];
-	enum placement_policy policy;
-	struct lmv_obd *lmv = &dev->u.lmv;
-
-	memcpy(dummy, buffer, MAX_POLICY_STRING_SIZE);
-
-	if (count > MAX_POLICY_STRING_SIZE)
-		count = MAX_POLICY_STRING_SIZE;
-
-	if (dummy[count - 1] == '\n')
-		count--;
-	dummy[count] = '\0';
-
-	policy = placement_name2policy(dummy, count);
-	if (policy != PLACEMENT_INVAL_POLICY) {
-		spin_lock(&lmv->lmv_lock);
-		lmv->lmv_placement = policy;
-		spin_unlock(&lmv->lmv_lock);
-	} else {
-		return -EINVAL;
-	}
-	return count;
-}
-LUSTRE_RW_ATTR(placement);
-
 static ssize_t activeobd_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
 {
@@ -226,7 +159,6 @@ static int lmv_target_seq_open(struct inode *inode, struct file *file)
 static struct attribute *lmv_attrs[] = {
 	&lustre_attr_activeobd.attr,
 	&lustre_attr_numobd.attr,
-	&lustre_attr_placement.attr,
 	NULL,
 };
 
-- 
1.8.3.1
