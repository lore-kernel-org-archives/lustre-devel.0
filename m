From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:51 -0500
Subject: [lustre-devel] [PATCH 423/622] lustre: mdc: hold lock while walking
 changelog dev list
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-424-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

In mdc_changelog_cdev_finish() we need chlg_registered_dev_lock
while walking and changing entries on the chlog_registered_devs
and ced_obds lists in chlg_registered_dev_find_by_obd().

Move the calling of chlg_registered_dev_find_by_obd() under the
mutex, and add assertions to the places where the lists are walked
and changed that the mutex is held.

Fixes: dfecb064ac1f ("lustre: mdc: expose changelog through char devices")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12566
Lustre-commit: a260c530801d ("LU-12566 mdc: hold lock while walking changelog dev list")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35668
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_changelog.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index ea74bab..9af0541 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -677,6 +677,7 @@ static void get_chlg_name(char *name, size_t name_len, struct obd_device *obd)
 {
 	struct chlg_registered_dev *dit;
 
+	LASSERT(mutex_is_locked(&chlg_registered_dev_lock));
 	list_for_each_entry(dit, &chlg_registered_devices, ced_link)
 		if (strcmp(name, dit->ced_name) == 0)
 			return dit;
@@ -695,6 +696,7 @@ static void get_chlg_name(char *name, size_t name_len, struct obd_device *obd)
 	struct chlg_registered_dev *dit;
 	struct obd_device *oit;
 
+	LASSERT(mutex_is_locked(&chlg_registered_dev_lock));
 	list_for_each_entry(dit, &chlg_registered_devices, ced_link)
 		list_for_each_entry(oit, &dit->ced_obds,
 				    u.cli.cl_chg_dev_linkage)
@@ -768,6 +770,7 @@ static void chlg_dev_clear(struct kref *kref)
 	struct chlg_registered_dev *entry = container_of(kref,
 							 struct chlg_registered_dev,
 							 ced_refs);
+	LASSERT(mutex_is_locked(&chlg_registered_dev_lock));
 	list_del(&entry->ced_link);
 	misc_deregister(&entry->ced_misc);
 	kfree(entry);
@@ -778,9 +781,10 @@ static void chlg_dev_clear(struct kref *kref)
  */
 void mdc_changelog_cdev_finish(struct obd_device *obd)
 {
-	struct chlg_registered_dev *dev = chlg_registered_dev_find_by_obd(obd);
+	struct chlg_registered_dev *dev;
 
 	mutex_lock(&chlg_registered_dev_lock);
+	dev = chlg_registered_dev_find_by_obd(obd);
 	list_del_init(&obd->u.cli.cl_chg_dev_linkage);
 	kref_put(&dev->ced_refs, chlg_dev_clear);
 	mutex_unlock(&chlg_registered_dev_lock);
-- 
1.8.3.1
