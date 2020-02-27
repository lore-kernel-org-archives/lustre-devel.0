From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:40 -0500
Subject: [lustre-devel] [PATCH 112/622] lustre: mdt: revoke lease lock for
 truncate
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-113-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jian Yu <yujian@whamcloud.com>

Lustre lease lock is usually used to protect file data
against concurrent access. Open lock used on MDT side
is for this purpose. However, truncate will change
file data but it doesn't revoke lease lock.

This patch fixes the issue by acquiring open sem,
checking lease count and revoking lease if there exists
any pending lease on the file.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10660
Lustre-commit: e4c168165df2 ("LU-10660 mdt: revoke lease lock for truncate")
Signed-off-by: Jian Yu <yujian@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33093
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c            | 7 +++++++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 2 files changed, 8 insertions(+)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 8b3e2a3..37558a8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1616,6 +1616,13 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 		clear_bit(LLIF_DATA_MODIFIED, &lli->lli_flags);
 	}
 
+	if (attr->ia_valid & ATTR_FILE) {
+		struct ll_file_data *fd = LUSTRE_FPRIVATE(attr->ia_file);
+
+		if (fd->fd_lease_och)
+			op_data->op_bias |= MDS_TRUNC_KEEP_LEASE;
+	}
+
 	op_data->op_attr = *attr;
 	op_data->op_xvalid = xvalid;
 
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index c65663a..7f857be 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1700,6 +1700,7 @@ enum mds_op_bias {
 	MDS_CLOSE_LAYOUT_MERGE	= 1 << 15,
 	MDS_CLOSE_RESYNC_DONE	= 1 << 16,
 	MDS_CLOSE_LAYOUT_SPLIT	= 1 << 17,
+	MDS_TRUNC_KEEP_LEASE	= 1 << 18,
 };
 
 #define MDS_CLOSE_INTENT (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |         \
-- 
1.8.3.1
