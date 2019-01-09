From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 22/29] lustre: osc_cache:
 osc_prep_async_page() has meaningless return
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504248.26726.14014358069894794630.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

osc_prep_async_page() is only called by osc_page_init(),
which immediately returns any non-zero return value.
osc_page_init is a ->coo_page_init() function, only called
by cl_page_alloc(), which treats any non-zero return as a
negative error number.

So osc_prep_async_page() must return 0 or a negative error.
Currently it can return
  cfs_size_round(sizeof(*oap))
which is either of those.

Presumably this condition never happens, so the return value is
irrelevant.
We could make it an LASSERT(), but it is safer to just return
an generic error.  So make it
  return -EIO;

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index b2ad6a15014e..8a68d3eb9314 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2287,7 +2287,7 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 	struct osc_async_page *oap = &ops->ops_oap;
 
 	if (!page)
-		return cfs_size_round(sizeof(*oap));
+		return -EIO;
 
 	oap->oap_magic = OAP_MAGIC;
 	oap->oap_cli = &exp->exp_obd->u.cli;
