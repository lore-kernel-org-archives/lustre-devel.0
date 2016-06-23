From: Lidza Louina <Lidza.Louina@oracle.com>
Date: Thu, 23 Jun 2016 13:24:25 -0400
Subject: [lustre-devel] [PATCH] staging/lustre/lnet: correctly casts value
	for arithmetic
Message-ID: <1466702665.3759.5.camel@lidza-VirtualBox>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The code attempted to add an unsigned int to a an unsigned 64-bit
integer. This patch casts the unsigned regular int to suppress
smatch warnings.

Signed-off-by: Lidza Louina <Lidza.Louina@oracle.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 346db89..5ecb2c7 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -513,7 +513,7 @@ lnet_res_lh_initialize(struct lnet_res_container *rec, lnet_libhandle_t *lh)
 	unsigned int hash;
 
 	lh->lh_cookie = rec->rec_lh_cookie;
-	rec->rec_lh_cookie += 1 << ibits;
+	rec->rec_lh_cookie += (__u64)(1 << ibits);
 
 	hash = (lh->lh_cookie >> ibits) & LNET_LH_HASH_MASK;
 
-- 
1.9.1
