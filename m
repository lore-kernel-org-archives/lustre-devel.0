From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 12:21:01 -0400
Subject: [lustre-devel] [PATCH 11/14] staging: lustre: llite: use proper
	types in the xattr code
In-Reply-To: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
References: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502727664-29438-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Convert __uXX types to uXX types since this is kernel code.
The function ll_lov_user_md_size() returns ssize_t so change
lum_size from int to ssize_t.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/27240
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 64fa65a..ff11dd8 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -91,7 +91,7 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 	struct ptlrpc_request *req = NULL;
 	const char *pv = value;
 	char *fullname;
-	__u64 valid;
+	u64 valid;
 	int rc;
 
 	if (flags == XATTR_REPLACE) {
@@ -247,8 +247,8 @@ static int ll_setstripe_ea(struct dentry *dentry, struct lov_user_md *lump,
 		return rc;
 
 	if (lump && S_ISREG(inode->i_mode)) {
-		__u64 it_flags = FMODE_WRITE;
-		int lum_size;
+		u64 it_flags = FMODE_WRITE;
+		ssize_t lum_size;
 
 		lum_size = ll_lov_user_md_size(lump);
 		if (lum_size < 0 || size < lum_size)
@@ -310,7 +310,7 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 
 int
 ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
-	      size_t size, __u64 valid)
+	      size_t size, u64 valid)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
-- 
1.8.3.1
