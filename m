From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:54 +1100
Subject: [lustre-devel] [PATCH 06/12] staging: lustre: lov: use
 list_for_each_entry in lov_obd.c
In-Reply-To: <151313493380.27582.16490205348451477393.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
Message-ID: <151313495494.27582.10063352335868964856.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Using the *_entry macro simplifies the code slightly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/lov/lov_obd.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 7ce01026a409..ec70c12e5b40 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -828,11 +828,9 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
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
