From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:29 -0400
Subject: [lustre-devel] [PATCH 16/80] staging: lustre: obdclass: bug fixes
	for lu_device_type handling
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

There was no protection when inc/dec lu_device_type::ldt_device_nr,
which may caused the ldt_device_nr to be wrong and trigger assert.
This patch redefine lu_device_type::ldt_device_nr as atomic type.

There was no protection when add/del lu_device_type::ldt_linkage
into/from the global lu_device_types list, which may caused bad
address accessing. This patch uses the existing obd_types_lock
to protect related operations.

We do NOT need lu_types_stop() any longer. Such function scans
the global lu_device_types list, and for each type item on it
which has zerod lu_device_type::ldt_device_nr, call its stop()
method. In fact, the lu_device_type::ldt_device_nr only will be
zero when the last lu_device_fini() is called, and at that time,
inside the lu_device_fini(), its stop() method will be called.
So it is unnecessary to call the stop() again via lu_types_stop().

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4604
Reviewed-on: http://review.whamcloud.com/8694
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |    3 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    6 ---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   34 ++++++++++----------
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    1 -
 4 files changed, 18 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 6e25c1b..25c12d8 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -327,7 +327,7 @@ struct lu_device_type {
 	/**
 	 * Number of existing device type instances.
 	 */
-	unsigned				ldt_device_nr;
+	atomic_t				ldt_device_nr;
 	/**
 	 * Linkage into a global list of all device types.
 	 *
@@ -673,7 +673,6 @@ void lu_object_add(struct lu_object *before, struct lu_object *o);
 
 int  lu_device_type_init(struct lu_device_type *ldt);
 void lu_device_type_fini(struct lu_device_type *ldt);
-void lu_types_stop(void);
 
 /** @} ctors */
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index e623216..771c0bd 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -368,12 +368,6 @@ int cl_sb_fini(struct super_block *sb)
 		CERROR("Cannot cleanup cl-stack due to memory shortage.\n");
 		result = PTR_ERR(env);
 	}
-	/*
-	 * If mount failed (sbi->ll_cl == NULL), and this there are no other
-	 * mounts, stop device types manually (this usually happens
-	 * automatically when last device is destroyed).
-	 */
-	lu_types_stop();
 	return result;
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 9b03059..0c00bf8 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -726,34 +726,31 @@ int lu_device_type_init(struct lu_device_type *ldt)
 {
 	int result = 0;
 
+	atomic_set(&ldt->ldt_device_nr, 0);
 	INIT_LIST_HEAD(&ldt->ldt_linkage);
 	if (ldt->ldt_ops->ldto_init)
 		result = ldt->ldt_ops->ldto_init(ldt);
-	if (result == 0)
+
+	if (!result) {
+		spin_lock(&obd_types_lock);
 		list_add(&ldt->ldt_linkage, &lu_device_types);
+		spin_unlock(&obd_types_lock);
+	}
+
 	return result;
 }
 EXPORT_SYMBOL(lu_device_type_init);
 
 void lu_device_type_fini(struct lu_device_type *ldt)
 {
+	spin_lock(&obd_types_lock);
 	list_del_init(&ldt->ldt_linkage);
+	spin_unlock(&obd_types_lock);
 	if (ldt->ldt_ops->ldto_fini)
 		ldt->ldt_ops->ldto_fini(ldt);
 }
 EXPORT_SYMBOL(lu_device_type_fini);
 
-void lu_types_stop(void)
-{
-	struct lu_device_type *ldt;
-
-	list_for_each_entry(ldt, &lu_device_types, ldt_linkage) {
-		if (ldt->ldt_device_nr == 0 && ldt->ldt_ops->ldto_stop)
-			ldt->ldt_ops->ldto_stop(ldt);
-	}
-}
-EXPORT_SYMBOL(lu_types_stop);
-
 /**
  * Global list of all sites on this node
  */
@@ -1082,8 +1079,10 @@ EXPORT_SYMBOL(lu_device_put);
  */
 int lu_device_init(struct lu_device *d, struct lu_device_type *t)
 {
-	if (t->ldt_device_nr++ == 0 && t->ldt_ops->ldto_start)
+	if (atomic_inc_return(&t->ldt_device_nr) == 1 &&
+	    t->ldt_ops->ldto_start)
 		t->ldt_ops->ldto_start(t);
+
 	memset(d, 0, sizeof(*d));
 	atomic_set(&d->ld_ref, 0);
 	d->ld_type = t;
@@ -1098,9 +1097,8 @@ EXPORT_SYMBOL(lu_device_init);
  */
 void lu_device_fini(struct lu_device *d)
 {
-	struct lu_device_type *t;
+	struct lu_device_type *t = d->ld_type;
 
-	t = d->ld_type;
 	if (d->ld_obd) {
 		d->ld_obd->obd_lu_dev = NULL;
 		d->ld_obd = NULL;
@@ -1109,8 +1107,10 @@ void lu_device_fini(struct lu_device *d)
 	lu_ref_fini(&d->ld_reference);
 	LASSERTF(atomic_read(&d->ld_ref) == 0,
 		 "Refcount is %u\n", atomic_read(&d->ld_ref));
-	LASSERT(t->ldt_device_nr > 0);
-	if (--t->ldt_device_nr == 0 && t->ldt_ops->ldto_stop)
+	LASSERT(atomic_read(&t->ldt_device_nr) > 0);
+
+	if (atomic_dec_and_test(&t->ldt_device_nr) &&
+	    t->ldt_ops->ldto_stop)
 		t->ldt_ops->ldto_stop(t);
 }
 EXPORT_SYMBOL(lu_device_fini);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 4931e37..33d6c42 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -670,7 +670,6 @@ int lustre_common_put_super(struct super_block *sb)
 	}
 	/* Drop a ref to the mounted disk */
 	lustre_put_lsi(sb);
-	lu_types_stop();
 	return rc;
 }
 EXPORT_SYMBOL(lustre_common_put_super);
-- 
1.7.1
