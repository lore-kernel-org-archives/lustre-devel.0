From: NeilBrown <neilb@suse.com>
Date: Wed, 07 Nov 2018 12:09:53 +1100
Subject: [lustre-devel] [PATCH/RFC] lustre: changelog_cdev need to find obd
 on each access.
In-Reply-To: <87d0rhybe2.fsf@notabene.neil.brown.name>
References: <87bm7a3nue.fsf@notabene.neil.brown.name>
 <7db27e7d-e685-af8f-80d8-891a0d8db4d5@cea.fr>
 <875zxh3elu.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1811042131490.27308@casper.infradead.org>
 <88ccd141-4778-e3ab-3ce0-e7cbd5c290fc@cea.fr>
 <87wopqyk5h.fsf@notabene.neil.brown.name>
 <a513884a-046f-a28c-3fbb-dd112abd4b26@cea.fr>
 <87d0rhybe2.fsf@notabene.neil.brown.name>
Message-ID: <877ehpy9pa.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


A changelog cdev can be held open indefinitely, and obd structures can
come and go while it is open.  So it isn't safe to choose and obd
at open time, and continue to use it.

Instead, we need to choose and obd on each access that needs it, and
hold the chlg_registered_dev_lock mutex while using the obd.  This
prevents the obd from being freed.

To help with this, we store a link to the chlg_registered_dev
in the chlg_reader_state, and use the name of the dev (instead
of the name of the obd) in some error messages.

Reported-by: Quentin Bouget <quentin.bouget@cea.fr>
Signed-off-by: NeilBrown <neilb@suse.com>
---

This is and RFC - I have only compile-tested it.
It seems sensible to me, but I know little about what is happening
here so I could easily be missing something important.

See also https://jira.whamcloud.com/browse/LU-11626

Thanks,
NeilBrown



 drivers/staging/lustre/lustre/mdc/mdc_changelog.c | 50 ++++++++++++++++-------
 1 file changed, 36 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_changelog.c b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
index becdee86f4d2..ee4b1b95408d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
@@ -66,8 +66,8 @@ struct chlg_registered_dev {
 };
 
 struct chlg_reader_state {
-	/* Shortcut to the corresponding OBD device */
-	struct obd_device	*crs_obd;
+	/* Device this state is associated with */
+	struct chlg_registered_dev *crs_dev;
 	/* Producer thread (if any) */
 	struct task_struct	*crs_prod_task;
 	/* An error occurred that prevents from reading further */
@@ -132,7 +132,7 @@ static int chlg_read_cat_process_cb(const struct lu_env *env,
 	if (rec->cr_hdr.lrh_type != CHANGELOG_REC) {
 		rc = -EINVAL;
 		CERROR("%s: not a changelog rec %x/%d in llog : rc = %d\n",
-		       crs->crs_obd->obd_name, rec->cr_hdr.lrh_type,
+		       crs->crs_dev->ced_name, rec->cr_hdr.lrh_type,
 		       rec->cr.cr_type, rc);
 		return rc;
 	}
@@ -183,6 +183,17 @@ static void enq_record_delete(struct chlg_rec_entry *rec)
 	kfree(rec);
 }
 
+/*
+ * Find any OBD device associated with this reader
+ * chlg_registered_dev_lock is held.
+ */
+static inline struct obd_device *chlg_obd_get(struct chlg_registered_dev *dev)
+{
+	return list_first_entry_or_null(&dev->ced_obds,
+					struct obd_device,
+					u.cli.cl_chg_dev_linkage);
+}
+
 /**
  * Record prefetch thread entry point. Opens the changelog catalog and starts
  * reading records.
@@ -193,11 +204,17 @@ static void enq_record_delete(struct chlg_rec_entry *rec)
 static int chlg_load(void *args)
 {
 	struct chlg_reader_state *crs = args;
-	struct obd_device *obd = crs->crs_obd;
+	struct obd_device *obd;
 	struct llog_ctxt *ctx = NULL;
 	struct llog_handle *llh = NULL;
 	int rc;
 
+	mutex_lock(&chlg_registered_dev_lock);
+	obd = chlg_obd_get(crs->crs_dev);
+	if (!obd) {
+		rc = -ENOENT;
+		goto err_out;
+	}
 	ctx = llog_get_context(obd, LLOG_CHANGELOG_REPL_CTXT);
 	if (!ctx) {
 		rc = -ENOENT;
@@ -230,6 +247,7 @@ static int chlg_load(void *args)
 	crs->crs_eof = true;
 
 err_out:
+	mutex_unlock(&chlg_registered_dev_lock);
 	if (rc < 0)
 		crs->crs_err = true;
 
@@ -387,15 +405,23 @@ static loff_t chlg_llseek(struct file *file, loff_t off, int whence)
  */
 static int chlg_clear(struct chlg_reader_state *crs, u32 reader, u64 record)
 {
-	struct obd_device *obd = crs->crs_obd;
+	struct obd_device *obd;
 	struct changelog_setinfo cs  = {
 		.cs_recno = record,
 		.cs_id    = reader
 	};
+	int ret;
 
-	return obd_set_info_async(NULL, obd->obd_self_export,
-				  strlen(KEY_CHANGELOG_CLEAR),
-				  KEY_CHANGELOG_CLEAR, sizeof(cs), &cs, NULL);
+	mutex_lock(&chlg_registered_dev_lock);
+	obd = chlg_obd_get(crs->crs_dev);
+	if (!obd)
+		ret = -ENOENT;
+	else
+		ret = obd_set_info_async(NULL, obd->obd_self_export,
+					 strlen(KEY_CHANGELOG_CLEAR),
+					 KEY_CHANGELOG_CLEAR, sizeof(cs), &cs, NULL);
+	mutex_unlock(&chlg_registered_dev_lock);
+	return ret;
 }
 
 /** Maximum changelog control command size */
@@ -456,20 +482,16 @@ static int chlg_open(struct inode *inode, struct file *file)
 	struct chlg_reader_state *crs;
 	struct miscdevice *misc = file->private_data;
 	struct chlg_registered_dev *dev;
-	struct obd_device *obd;
 	struct task_struct *task;
 	int rc;
 
 	dev = container_of(misc, struct chlg_registered_dev, ced_misc);
-	obd = list_first_entry(&dev->ced_obds,
-			       struct obd_device,
-			       u.cli.cl_chg_dev_linkage);
 
 	crs = kzalloc(sizeof(*crs), GFP_KERNEL);
 	if (!crs)
 		return -ENOMEM;
 
-	crs->crs_obd = obd;
+	crs->crs_dev = dev;
 	crs->crs_err = false;
 	crs->crs_eof = false;
 
@@ -483,7 +505,7 @@ static int chlg_open(struct inode *inode, struct file *file)
 		if (IS_ERR(task)) {
 			rc = PTR_ERR(task);
 			CERROR("%s: cannot start changelog thread: rc = %d\n",
-			       obd->obd_name, rc);
+			       dev->ced_name, rc);
 			goto err_crs;
 		}
 		crs->crs_prod_task = task;
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181107/c50ffabf/attachment.sig>
