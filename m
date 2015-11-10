From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Tue, 10 Nov 2015 10:26:36 +0530
Subject: [lustre-devel] [PATCH v2 4/8] Staging: lustre: xattr_cache: Change
	function calls to kfree
In-Reply-To: <cover.1447129813.git.shivanib134@gmail.com>
References: <cover.1447129813.git.shivanib134@gmail.com>
Message-ID: <1999e1d863939bed3d168841eabb5b8d16ea36b8.1447129813.git.shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Change the calls of the function ll_finish_md_op_data() to the
standard function kfree().

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
Changes in v2:
        Fix commit message and merge a patch

 drivers/staging/lustre/lustre/llite/xattr_cache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index e1e599c..b7f3efc 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -306,7 +306,7 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 	op_data->op_valid = OBD_MD_FLXATTR | OBD_MD_FLXATTRLS;
 
 	rc = md_enqueue(exp, &einfo, oit, op_data, &lockh, NULL, 0, NULL, 0);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 
 	if (rc < 0) {
 		CDEBUG(D_CACHE,
-- 
2.1.0
