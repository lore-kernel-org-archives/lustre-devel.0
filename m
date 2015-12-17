From: Shraddha <shraddha.6596@gmail.com>
Date: Fri, 18 Dec 2015 02:40:30 +0530
Subject: [lustre-devel] [PATCH 5/5] Staging: lustre: obdclass: Declare
	lu_site_hash_ops as static
In-Reply-To: <1450386630-5662-1-git-send-email-shraddha.6596@gmail.com>
References: <1450386630-5662-1-git-send-email-shraddha.6596@gmail.com>
Message-ID: <1450386630-5662-6-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shraddha Barke <shraddha.6596@gmail.com>

lu_site_hash_ops is used only in this particular file. Thus declare
it as static.

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 0193608..c47c544 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -916,7 +916,7 @@ static void lu_obj_hop_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
 	LBUG(); /* we should never called it */
 }
 
-struct cfs_hash_ops lu_site_hash_ops = {
+static struct cfs_hash_ops lu_site_hash_ops = {
 	.hs_hash	= lu_obj_hop_hash,
 	.hs_key		= lu_obj_hop_key,
 	.hs_keycmp      = lu_obj_hop_keycmp,
-- 
2.1.4
