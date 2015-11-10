From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Tue, 10 Nov 2015 10:28:05 +0530
Subject: [lustre-devel] [PATCH v2 6/8] Staging: lustre: llite_nfs: Replace
	function calls with kfree
In-Reply-To: <cover.1447129813.git.shivanib134@gmail.com>
References: <cover.1447129813.git.shivanib134@gmail.com>
Message-ID: <848f14d901de90a54298e65fb017dbe9cd841081.1447129813.git.shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replace the calls of the function ll_finish_md_op_data() with the
standard function kfree().

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
Changes in v2:
        Fix commit message and merge a patch

 drivers/staging/lustre/lustre/llite/llite_nfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index e578a11..a3a89a7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -306,7 +306,7 @@ static struct dentry *ll_get_parent(struct dentry *dchild)
 		return (void *)op_data;
 
 	rc = md_getattr_name(sbi->ll_md_exp, op_data, &req);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (rc) {
 		CERROR("failure %d inode %lu get parent\n", rc, dir->i_ino);
 		return ERR_PTR(rc);
-- 
2.1.0
