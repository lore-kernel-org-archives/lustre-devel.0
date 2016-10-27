From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:55 -0400
Subject: [lustre-devel] [PATCH 21/29] staging: lustre: obdclass: race
	lustre_profile_list
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Hiroya Nozaki <nozaki.hiroya@jp.fujitsu.com>, James Simmons <jsimmons@infradead.org>

From: Hiroya Nozaki <nozaki.hiroya@jp.fujitsu.com>

Running multiple mounts at the same time results in
lustre_profile_list corruption when adding a new profile.

This patch adds a new spin_lock to protect the list and
avoid the bug

Signed-off-by: Hiroya Nozaki <nozaki.hiroya@jp.fujitsu.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6600
Reviewed-on: http://review.whamcloud.com/14896
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_class.h  |    3 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 +
 .../staging/lustre/lustre/obdclass/obd_config.c    |   57 +++++++++++++++++---
 3 files changed, 54 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 476b1e4..f79133c 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -182,10 +182,13 @@ struct lustre_profile {
 	char	    *lp_profile;
 	char	    *lp_dt;
 	char	    *lp_md;
+	int			lp_refs;
+	bool			lp_list_deleted;
 };
 
 struct lustre_profile *class_get_profile(const char *prof);
 void class_del_profile(const char *prof);
+void class_put_profile(struct lustre_profile *lprof);
 void class_del_profiles(void);
 
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index b896ac1..308da06 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -929,6 +929,8 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
 out_free:
 	kfree(md);
 	kfree(dt);
+	if (lprof)
+		class_put_profile(lprof);
 	if (err)
 		ll_put_super(sb);
 	else if (sbi->ll_flags & LL_SBI_VERBOSE)
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index bbed1b7..017bdac 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -585,16 +585,21 @@ static int class_del_conn(struct obd_device *obd, struct lustre_cfg *lcfg)
 }
 
 static LIST_HEAD(lustre_profile_list);
+static DEFINE_SPINLOCK(lustre_profile_list_lock);
 
 struct lustre_profile *class_get_profile(const char *prof)
 {
 	struct lustre_profile *lprof;
 
+	spin_lock(&lustre_profile_list_lock);
 	list_for_each_entry(lprof, &lustre_profile_list, lp_list) {
 		if (!strcmp(lprof->lp_profile, prof)) {
+			lprof->lp_refs++;
+			spin_unlock(&lustre_profile_list_lock);
 			return lprof;
 		}
 	}
+	spin_unlock(&lustre_profile_list_lock);
 	return NULL;
 }
 EXPORT_SYMBOL(class_get_profile);
@@ -639,7 +644,11 @@ static int class_add_profile(int proflen, char *prof, int osclen, char *osc,
 		}
 	}
 
+	spin_lock(&lustre_profile_list_lock);
+	lprof->lp_refs = 1;
+	lprof->lp_list_deleted = false;
 	list_add(&lprof->lp_list, &lustre_profile_list);
+	spin_unlock(&lustre_profile_list_lock);
 	return err;
 
 free_lp_dt:
@@ -659,27 +668,59 @@ void class_del_profile(const char *prof)
 
 	lprof = class_get_profile(prof);
 	if (lprof) {
+		spin_lock(&lustre_profile_list_lock);
+		/* because get profile increments the ref counter */
+		lprof->lp_refs--;
 		list_del(&lprof->lp_list);
-		kfree(lprof->lp_profile);
-		kfree(lprof->lp_dt);
-		kfree(lprof->lp_md);
-		kfree(lprof);
+		lprof->lp_list_deleted = true;
+		spin_unlock(&lustre_profile_list_lock);
+
+		class_put_profile(lprof);
 	}
 }
 EXPORT_SYMBOL(class_del_profile);
 
+void class_put_profile(struct lustre_profile *lprof)
+{
+	spin_lock(&lustre_profile_list_lock);
+	if (--lprof->lp_refs > 0) {
+		LASSERT(lprof->lp_refs > 0);
+		spin_unlock(&lustre_profile_list_lock);
+		return;
+	}
+	spin_unlock(&lustre_profile_list_lock);
+
+	/* confirm not a negative number */
+	LASSERT(!lprof->lp_refs);
+
+	/*
+	 * At least one class_del_profile/profiles must be called
+	 * on the target profile or lustre_profile_list will corrupt
+	 */
+	LASSERT(lprof->lp_list_deleted);
+	kfree(lprof->lp_profile);
+	kfree(lprof->lp_dt);
+	kfree(lprof->lp_md);
+	kfree(lprof);
+}
+EXPORT_SYMBOL(class_put_profile);
+
 /* COMPAT_146 */
 void class_del_profiles(void)
 {
 	struct lustre_profile *lprof, *n;
 
+	spin_lock(&lustre_profile_list_lock);
 	list_for_each_entry_safe(lprof, n, &lustre_profile_list, lp_list) {
 		list_del(&lprof->lp_list);
-		kfree(lprof->lp_profile);
-		kfree(lprof->lp_dt);
-		kfree(lprof->lp_md);
-		kfree(lprof);
+		lprof->lp_list_deleted = true;
+		spin_unlock(&lustre_profile_list_lock);
+
+		class_put_profile(lprof);
+
+		spin_lock(&lustre_profile_list_lock);
 	}
+	spin_unlock(&lustre_profile_list_lock);
 }
 EXPORT_SYMBOL(class_del_profiles);
 
-- 
1.7.1
