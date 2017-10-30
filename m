From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Oct 2017 15:59:27 +1100
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: lov: use
 list_for_each_entry in lov_obd.c
In-Reply-To: <150933945578.22133.8029060522107378499.stgit@noble>
References: <150933945578.22133.8029060522107378499.stgit@noble>
Message-ID: <150933956729.22133.13130557672702877610.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/lov/lov_obd.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index fefd3c588681..7e013229d7b5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -827,11 +827,9 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 static int lov_cleanup(struct obd_device *obd)
 {
 	struct lov_obd *lov = &obd->u.lov;
-	struct list_head *pos, *tmp;
-	struct pool_desc *pool;
+	struct pool_desc *pool, *tmp;
 
-	list_for_each_safe(pos, tmp, &lov->lov_pool_list) {
-		pool = list_entry(pos, struct pool_desc, pool_list);
+	list_for_each_entry_safe(pool, tmp, &lov->lov_pool_list, pool_list) {
 		/* free pool structs */
 		CDEBUG(D_INFO, "delete pool %p\n", pool);
 		/* In the function below, .hs_keycmp resolves to
