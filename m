From: Ryan Swan <ryan@ryanswan.com>
Date: Mon, 17 Oct 2016 19:22:01 -0000
Subject: [lustre-devel] [PATCH] staging: lov.ko: lov_object.c: fix sparse
	warning setting function to static
Message-ID: <1476732112-21234-1-git-send-email-ryan@ryanswan.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fixed: sparse WARNING: symbol 'lov_read_and_clear_async_rc' was not declared. Should it be static?

Signed-off-by: Ryan Swan <ryan@ryanswan.com>
---
 drivers/staging/lustre/lustre/lov/lov_object.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 82b99e0..c42eef6 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -1532,7 +1532,7 @@ struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
 	return lsm;
 }
 
-int lov_read_and_clear_async_rc(struct cl_object *clob)
+static int lov_read_and_clear_async_rc(struct cl_object *clob)
 {
 	struct lu_object *luobj;
 	int rc = 0;
-- 
2.7.4
