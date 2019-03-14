From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:50 +1100
Subject: [lustre-devel] [PATCH 20/32] lustre: lnet: discard
 lnet_kvaddr_to_page
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231083.26912.3172808314490420973.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This function is no longer used, so discard it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 -
 drivers/staging/lustre/lnet/lnet/lib-md.c          |    9 ---------
 2 files changed, 10 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index fca1c19a3c84..ca5ce2520c47 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -603,7 +603,6 @@ void lnet_me_unlink(struct lnet_me *me);
 
 void lnet_md_unlink(struct lnet_libmd *md);
 void lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_event *ev);
-struct page *lnet_kvaddr_to_page(unsigned long vaddr);
 int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset);
 
 void lnet_register_lnd(struct lnet_lnd *lnd);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 4c6d14aa2139..c61f0286b21b 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -85,15 +85,6 @@ lnet_md_unlink(struct lnet_libmd *md)
 	kfree(md);
 }
 
-struct page *lnet_kvaddr_to_page(unsigned long vaddr)
-{
-	if (is_vmalloc_addr((void *)vaddr))
-		return vmalloc_to_page((void *)vaddr);
-
-	return kmap_to_page((void *)vaddr);
-}
-EXPORT_SYMBOL(lnet_kvaddr_to_page);
-
 int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 {
 	int cpt = CFS_CPT_ANY;
