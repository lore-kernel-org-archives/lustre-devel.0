From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 12:20:58 -0400
Subject: [lustre-devel] [PATCH 08/14] staging: lustre: llite: fix invalid
	size test in ll_setstripe_ea()
In-Reply-To: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
References: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502727664-29438-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The size check at the start of ll_setstripe_ea() is only
valid for a directory. Move that check to the section of
code handling the S_ISDIR case.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/27240
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 86b5df9..a54be09 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -235,9 +235,6 @@ static int ll_setstripe_ea(struct dentry *dentry, struct lov_user_md *lump,
 	struct inode *inode = d_inode(dentry);
 	int rc = 0;
 
-	if (size != 0 && size < sizeof(struct lov_user_md))
-		return -EINVAL;
-
 	/*
 	 * It is possible to set an xattr to a "" value of zero size.
 	 * For this case we are going to treat it as a removal.
@@ -270,6 +267,9 @@ static int ll_setstripe_ea(struct dentry *dentry, struct lov_user_md *lump,
 		if (rc == -EEXIST)
 			rc = 0;
 	} else if (S_ISDIR(inode->i_mode)) {
+		if (size != 0 && size < sizeof(struct lov_user_md))
+			return -EINVAL;
+
 		rc = ll_dir_setstripe(inode, lump, 0);
 	}
 
-- 
1.8.3.1
