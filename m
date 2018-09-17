From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:40 -0400
Subject: [lustre-devel] [PATCH 30/30] lustre: clio: fix spare bit handling
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Expanded testing of the earlier patch that changed lustre so not
to use the spare bits in iattr.ia_valid exposed a bug with HSM.
The bugs was that ll_setattr_raw() was ignoring the changes to
ctime.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10030
Reviewed-on: https://review.whamcloud.com/32825
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 99d0b72..3de6e886 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1529,7 +1529,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 	}
 
 	/* We mark all of the fields "set" so MDS/OST does not re-set them */
-	if (attr->ia_valid & ATTR_CTIME) {
+	if (!(xvalid & OP_ATTR_CTIME_SET) &&
+	    attr->ia_valid & ATTR_CTIME) {
 		attr->ia_ctime = current_time(inode);
 		xvalid |= OP_ATTR_CTIME_SET;
 	}
@@ -1584,9 +1585,9 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 		goto out;
 	}
 
-	if (attr->ia_valid & (ATTR_SIZE |
-			      ATTR_ATIME | ATTR_ATIME_SET |
-			      ATTR_MTIME | ATTR_MTIME_SET)) {
+	if (attr->ia_valid & (ATTR_SIZE | ATTR_ATIME | ATTR_ATIME_SET |
+			      ATTR_MTIME | ATTR_MTIME_SET | ATTR_CTIME) ||
+	    xvalid & OP_ATTR_CTIME_SET) {
 		/* For truncate and utimes sending attributes to OSTs, setting
 		 * mtime/atime to the past will be performed under PW [0:EOF]
 		 * extent lock (new_size:EOF for truncate).  It may seem
-- 
1.8.3.1
