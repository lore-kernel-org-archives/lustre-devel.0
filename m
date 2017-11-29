From: NeilBrown <neilb@suse.com>
Date: Wed, 29 Nov 2017 14:01:12 +1100
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: lov: use
 list_for_each_entry in lov_obd.c
In-Reply-To: <20171124154341.GA16654@kroah.com>
References: <150933945578.22133.8029060522107378499.stgit@noble>
 <150933956729.22133.13130557672702877610.stgit@noble>
 <20171124154341.GA16654@kroah.com>
Message-ID: <87r2shwzyf.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Subject: [PATCH] staging: lustre: lov: use list_for_each_entry in lov_obd.c

Using the *_entry macro simplifies the code slightly.

Signed-off-by: NeilBrown <neilb@suse.com>
---

Resubmitted with non-empty changelog text.

Thanks,
NeilBrown

 drivers/staging/lustre/lustre/lov/lov_obd.c | 6 ++----
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
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171129/c4003335/attachment.sig>
