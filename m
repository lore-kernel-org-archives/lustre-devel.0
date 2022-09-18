Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1732BC32771
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:23:06 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmn5gG4z215W;
	Sat, 17 Sep 2022 22:23:05 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbm92QZ8z1yC1
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:33 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1016B8F14;
 Sun, 18 Sep 2022 01:22:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0E9401CA2D; Sun, 18 Sep 2022 01:22:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:22:10 -0400
Message-Id: <1663478534-19917-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/24] lustre: flr: allow layout version
 update from client/MDS
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Bobi Jam <bobijam@whamcloud.com>

Client write request always carries its layout version so
that OFD can reject the request if the carried layout version
is a stale one.

This patch makes OFD allow layout version change request from
client as well as MDS. And during resync write, all OST objects
will get layout version updated.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14642
Lustre-commit: fa6574150b6f745a66 ("LU-14642 flr: allow layout version update from client/MDS")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45443
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h         |  2 +-
 fs/lustre/llite/file.c                  | 30 +++++++++++-------------------
 include/uapi/linux/lustre/lustre_user.h | 15 ++++++++++-----
 3 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 0909351..c98c8a4 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -517,7 +517,7 @@
 
 /* FLR */
 #define OBD_FAIL_FLR_LV_DELAY				0x1A01
-#define OBD_FAIL_FLR_LV_INC				0x1A02
+#define OBD_FAIL_FLR_LV_INC				0x1A02 /* unused since 2.15 */
 #define OBD_FAIL_FLR_RANDOM_PICK_MIRROR			0x1A03
 
 /* LNet is allocated failure locations 0xe000 to 0xffff */
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 5394cce..e75f482 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3553,6 +3553,7 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 	bool lease_broken = false;
 	fmode_t fmode = 0;
 	enum mds_op_bias bias = 0;
+	int fdv;
 	struct file *layout_file = NULL;
 	void *data = NULL;
 	size_t data_size = 0;
@@ -3592,21 +3593,19 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 
 		bias = MDS_CLOSE_RESYNC_DONE;
 		break;
-	case LL_LEASE_LAYOUT_MERGE: {
-		int fd;
-
+	case LL_LEASE_LAYOUT_MERGE:
 		if (ioc->lil_count != 1) {
 			rc = -EINVAL;
 			goto out_lease_close;
 		}
 
 		arg += sizeof(*ioc);
-		if (copy_from_user(&fd, (void __user *)arg, sizeof(u32))) {
+		if (copy_from_user(&fdv, (void __user *)arg, sizeof(u32))) {
 			rc = -EFAULT;
 			goto out_lease_close;
 		}
 
-		layout_file = fget(fd);
+		layout_file = fget(fdv);
 		if (!layout_file) {
 			rc = -EBADF;
 			goto out_lease_close;
@@ -3621,9 +3620,7 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		data = file_inode(layout_file);
 		bias = MDS_CLOSE_LAYOUT_MERGE;
 		break;
-	}
 	case LL_LEASE_LAYOUT_SPLIT: {
-		int fdv;
 		int mirror_id;
 
 		if (ioc->lil_count != 2) {
@@ -3700,29 +3697,24 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 
 	if (lease_broken)
 		fmode = 0;
-
 out:
-	switch (ioc->lil_flags) {
-	case LL_LEASE_RESYNC_DONE:
+	if (ioc->lil_flags == LL_LEASE_RESYNC_DONE && data)
 		kfree(data);
-		break;
-	case LL_LEASE_LAYOUT_MERGE:
-	case LL_LEASE_LAYOUT_SPLIT:
-		if (layout_file)
-			fput(layout_file);
 
-		ll_layout_refresh(inode, &fd->fd_layout_version);
-		break;
-	case LL_LEASE_PCC_ATTACH:
+	if (layout_file)
+		fput(layout_file);
+
+	if (ioc->lil_flags == LL_LEASE_PCC_ATTACH) {
 		if (!rc)
 			rc = rc2;
 		rc = pcc_readwrite_attach_fini(file, inode,
 					       param.pa_layout_gen,
 					       lease_broken, rc,
 					       attached);
-		break;
 	}
 
+	ll_layout_refresh(inode, &fd->fd_layout_version);
+
 	if (!rc)
 		rc = ll_lease_type_from_fmode(fmode);
 	return rc;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 8cfee7f..6577202 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -578,11 +578,6 @@ enum lov_comp_md_entry_flags {
 /* The mirror flags sent by client */
 #define LCME_MIRROR_FLAGS	(LCME_FL_NOSYNC)
 
-/* the highest bit in obdo::o_layout_version is used to mark if the file is
- * being resynced.
- */
-#define LU_LAYOUT_RESYNC	LCME_FL_NEG
-
 /* lcme_id can be specified as certain flags, and the first
  * bit of lcme_id is used to indicate that the ID is representing
  * certain LCME_FL_* but not a real ID. Which implies we can have
@@ -595,6 +590,16 @@ enum lcme_id {
 	LCME_ID_NOT_ID	= LCME_FL_NEG
 };
 
+/* layout version equals to lcme_id, except some bits have special meanings */
+enum layout_version_flags {
+	/* layout version reaches the high water mark to be increased to
+	 * circularly reuse the smallest value
+	 */
+	LU_LAYOUT_HIGEN		= 0x40000000,
+	/* the highest bit is used to mark if the file is being resynced */
+	LU_LAYOUT_RESYNC	= 0x80000000,
+};
+
 struct lov_comp_md_entry_v1 {
 	__u32			lcme_id;	/* unique id of component */
 	__u32			lcme_flags;	/* LCME_FL_XXX */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
