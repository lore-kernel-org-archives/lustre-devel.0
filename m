From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Tue, 10 Nov 2015 10:27:25 +0530
Subject: [lustre-devel] [PATCH v2 5/8] Staging: lustre: symlink: Substitute
	standard function
In-Reply-To: <cover.1447129813.git.shivanib134@gmail.com>
References: <cover.1447129813.git.shivanib134@gmail.com>
Message-ID: <b5d42a0ca4a0bbbb3b08b27459137b161962e3f9.1447129813.git.shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Substitute the standard function kfree() for the function
ll_finish_md_op_data().

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
Changes in v2:
        Fix commit message and merge a patch

 drivers/staging/lustre/lustre/llite/symlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index 69b2036..6b0d1cc 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -73,7 +73,7 @@ static int ll_readlink_internal(struct inode *inode,
 
 	op_data->op_valid = OBD_MD_LINKNAME;
 	rc = md_getattr(sbi->ll_md_exp, op_data, request);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (rc) {
 		if (rc != -ENOENT)
 			CERROR("inode %lu: rc = %d\n", inode->i_ino, rc);
-- 
2.1.0
