From: NeilBrown <neilb@suse.com>
Date: Fri, 02 Mar 2018 10:31:25 +1100
Subject: [lustre-devel] [PATCH 04/17] staging: lustre: obdclass: don't
 require lct_owner to be non-NULL.
In-Reply-To: <151994679573.7628.1024109499321778846.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
Message-ID: <151994708517.7628.10169180583984336095.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Some places in lu_object.c allow lct_owner to be NULL, implying
that the code is built in to the kernel (not a module), but
two places don't.  This prevents us from building lustre into
the kernel.

So remove the requirement and always allow lct_owner to be NULL.

This requires removing an "assert" that the module count is positive,
but this is redundant as module_put() already does the necessary test.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index cca688175d2d..880800e78c52 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1380,12 +1380,8 @@ static void key_fini(struct lu_context *ctx, int index)
 		lu_ref_del(&key->lct_reference, "ctx", ctx);
 		atomic_dec(&key->lct_used);
 
-		if ((ctx->lc_tags & LCT_NOREF) == 0) {
-#ifdef CONFIG_MODULE_UNLOAD
-			LINVRNT(module_refcount(key->lct_owner) > 0);
-#endif
+		if ((ctx->lc_tags & LCT_NOREF) == 0)
 			module_put(key->lct_owner);
-		}
 		ctx->lc_value[index] = NULL;
 	}
 }
@@ -1619,7 +1615,6 @@ static int keys_fill(struct lu_context *ctx)
 			LINVRNT(key->lct_init);
 			LINVRNT(key->lct_index == i);
 
-			LASSERT(key->lct_owner);
 			if (!(ctx->lc_tags & LCT_NOREF) &&
 			    !try_module_get(key->lct_owner)) {
 				/* module is unloading, skip this key */
