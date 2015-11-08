From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:06 -0500
Subject: [lustre-devel] [PATCH 01/13] staging: lustre: remove hsm_nl proc
	file
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: John L. Hammond <john.hammond@intel.com>

Remove the file /proc/fs/lustre/mdc/*/hsm_nl which was introduced "for
testing purposes."

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2489
Reviewed-on: http://review.whamcloud.com/6656
Reviewed-by: jacques-Charles Lafoucriere <jacques-charles.lafoucriere@cea.fr>
Reviewed-by: Aurelien Degremont <aurelien.degremont@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c |   77 -------------------------
 1 files changed, 0 insertions(+), 77 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 1c95f87..84e5862 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -82,82 +82,6 @@ static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(max_rpcs_in_flight);
 
-static int mdc_kuc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, NULL, inode->i_private);
-}
-
-/* temporary for testing */
-static ssize_t mdc_kuc_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
-{
-	struct obd_device *obd =
-			((struct seq_file *)file->private_data)->private;
-	struct kuc_hdr		*lh;
-	struct hsm_action_list	*hal;
-	struct hsm_action_item	*hai;
-	int			 len;
-	int			 fd, rc;
-
-	rc = lprocfs_write_helper(buffer, count, &fd);
-	if (rc)
-		return rc;
-
-	if (fd < 0)
-		return -ERANGE;
-	CWARN("message to fd %d\n", fd);
-
-	len = sizeof(*lh) + sizeof(*hal) + MTI_NAME_MAXLEN +
-		/* for mockup below */ 2 * cfs_size_round(sizeof(*hai));
-
-	lh = kzalloc(len, GFP_NOFS);
-	if (!lh)
-		return -ENOMEM;
-
-	lh->kuc_magic = KUC_MAGIC;
-	lh->kuc_transport = KUC_TRANSPORT_HSM;
-	lh->kuc_msgtype = HMT_ACTION_LIST;
-	lh->kuc_msglen = len;
-
-	hal = (struct hsm_action_list *)(lh + 1);
-	hal->hal_version = HAL_VERSION;
-	hal->hal_archive_id = 1;
-	hal->hal_flags = 0;
-	obd_uuid2fsname(hal->hal_fsname, obd->obd_name, MTI_NAME_MAXLEN);
-
-	/* mock up an action list */
-	hal->hal_count = 2;
-	hai = hai_zero(hal);
-	hai->hai_action = HSMA_ARCHIVE;
-	hai->hai_fid.f_oid = 5;
-	hai->hai_len = sizeof(*hai);
-	hai = hai_next(hai);
-	hai->hai_action = HSMA_RESTORE;
-	hai->hai_fid.f_oid = 10;
-	hai->hai_len = sizeof(*hai);
-
-	/* This works for either broadcast or unicast to a single fd */
-	if (fd == 0) {
-		rc = libcfs_kkuc_group_put(KUC_GRP_HSM, lh);
-	} else {
-		struct file *fp = fget(fd);
-
-		rc = libcfs_kkuc_msg_put(fp, lh);
-		fput(fp);
-	}
-	kfree(lh);
-	if (rc < 0)
-		return rc;
-	return count;
-}
-
-static struct file_operations mdc_kuc_fops = {
-	.open		= mdc_kuc_open,
-	.write		= mdc_kuc_write,
-	.release	= single_release,
-};
-
 LPROC_SEQ_FOPS_WR_ONLY(mdc, ping);
 
 LPROC_SEQ_FOPS_RO_TYPE(mdc, connect_flags);
@@ -196,7 +120,6 @@ static struct lprocfs_vars lprocfs_mdc_obd_vars[] = {
 	{ "timeouts",		&mdc_timeouts_fops,		NULL, 0 },
 	{ "import",		&mdc_import_fops,		NULL, 0 },
 	{ "state",		&mdc_state_fops,		NULL, 0 },
-	{ "hsm_nl",		&mdc_kuc_fops,			NULL, 0200 },
 	{ "pinger_recov",	&mdc_pinger_recov_fops,		NULL, 0 },
 	{ NULL }
 };
-- 
1.7.1
