From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:41 -0500
Subject: [lustre-devel] [PATCH 08/14] lustre: llite: op_data->op_valid is
 incorrect in ll_dir_getstripe
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The function ll_dir_getstripe() passes in valid but it was never
used to properly setup op_data->op_valid which prevented user
land applications from getting real directory striping
information. Apply the passed in valid parameter to the
op_data->op_valid field.

Fixes: 6e23ea986bf ("staging: lustre: llite: fix "getdirstripe" to show stripe info")
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 86b5c7a..0a7330d 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -631,7 +631,7 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	op_data->op_valid = OBD_MD_FLEASIZE | OBD_MD_FLDIREA;
+	op_data->op_valid = valid | OBD_MD_FLEASIZE | OBD_MD_FLDIREA;
 	rc = md_getattr(sbi->ll_md_exp, op_data, &req);
 	ll_finish_md_op_data(op_data);
 	if (rc < 0) {
-- 
1.8.3.1
