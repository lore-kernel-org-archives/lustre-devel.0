From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:59 -0500
Subject: [lustre-devel] [PATCH 011/622] lustre: llite: handle ORPHAN/DEAD
 directories
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Di Wang <di.wang@intel.com>

Don't set the directory MDS striping if the parent is dead.
To test this works add the OBD_FAIL_LLITE_NO_CHECK_DEAD
injection fault.

WC-bug-id: https://jira.whamcloud.com/browse/LU-7579
Lustre-commit: 098fb363c39 ("LU-7579 osd: move ORPHAN/DEAD flag to OSD")
Signed-off-by: Di Wang <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/18024
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 1 +
 fs/lustre/llite/dir.c           | 4 ++++
 2 files changed, 5 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index e10b372..653a456 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -442,6 +442,7 @@
 #define OBD_FAIL_LLITE_XATTR_ENOMEM			0x1405
 #define OBD_FAIL_MAKE_LOVEA_HOLE			0x1406
 #define OBD_FAIL_LLITE_LOST_LAYOUT			0x1407
+#define OBD_FAIL_LLITE_NO_CHECK_DEAD			0x1408
 #define OBD_FAIL_GETATTR_DELAY				0x1409
 #define OBD_FAIL_LLITE_CREATE_NODE_PAUSE		0x140c
 #define OBD_FAIL_LLITE_IMUTEX_SEC			0x140e
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index d3ef669..f21727b 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -433,6 +433,10 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	    !(exp_connect_flags(sbi->ll_md_exp) & OBD_CONNECT_DIR_STRIPE))
 		return -EINVAL;
 
+	if (IS_DEADDIR(parent) &&
+	    !OBD_FAIL_CHECK(OBD_FAIL_LLITE_NO_CHECK_DEAD))
+		return -ENOENT;
+
 	if (lump->lum_magic != cpu_to_le32(LMV_USER_MAGIC) &&
 	    lump->lum_magic != cpu_to_le32(LMV_USER_MAGIC_SPECIFIC))
 		lustre_swab_lmv_user_md(lump);
-- 
1.8.3.1
