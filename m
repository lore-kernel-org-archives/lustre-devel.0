From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:49 +1100
Subject: [lustre-devel] [PATCH 09/32] lustre: lnet: discard LNET_MD_PHYS
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230941.26912.14642481086398795309.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This macro has no value and is never set.
It claims "compatibility with Cray Portals".  If
that becomes a real issue in the future, it can be re-introduced.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |    3 ---
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |    3 +--
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
index 956af3c53cfc..9f912503a24c 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
@@ -543,9 +543,6 @@ struct lnet_md {
 /** See lnet_md::options. */
 #define LNET_MD_BULK_HANDLE	(1 << 9)
 
-/* For compatibility with Cray Portals */
-#define LNET_MD_PHYS		0
-
 /** Infinite threshold on MD operations. See lnet_md::threshold */
 #define LNET_MD_THRESH_INF	(-1)
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index 948ece11970f..6efa37ba7ded 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -50,8 +50,7 @@ void ptlrpc_fill_bulk_md(struct lnet_md *md, struct ptlrpc_bulk_desc *desc,
 
 	LASSERT(mdidx < desc->bd_md_max_brw);
 	LASSERT(desc->bd_iov_count <= PTLRPC_MAX_BRW_PAGES);
-	LASSERT(!(md->options & (LNET_MD_IOVEC | LNET_MD_KIOV |
-				 LNET_MD_PHYS)));
+	LASSERT(!(md->options & (LNET_MD_IOVEC | LNET_MD_KIOV)));
 
 	md->length = max(0, desc->bd_iov_count - mdidx * LNET_MAX_IOV);
 	md->length = min_t(unsigned int, LNET_MAX_IOV, md->length);
