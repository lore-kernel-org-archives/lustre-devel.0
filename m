From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:59 -0500
Subject: [lustre-devel] [PATCH 26/28] lustre: sec: encryption with different
 client PAGE_SIZE
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

In order to properly handle encryption/decryption on clients that have
a PAGE_SIZE != LUSTRE_ENCRYPTION_UNIT_SIZE (typically aarch64/ppc64),
a few adjustements are necessary:
- when encrypting, do not proceed with PAGE_SIZE as encryption length.
  Instead, round up to a multiple of LUSTRE_ENCRYPTION_UNIT_SIZE.
  On aarch64/ppc64, it avoids encrypting way beyond
  LUSTRE_ENCRYPTION_UNIT_SIZE when the page is not full.
- when decrypting, do not proceed with PAGE_SIZE as decryption length.
  Instead, do LUSTRE_ENCRYPTION_UNIT_SIZE length at a time. It enables
  proper detection of 'all 0s' sent by servers for content beyond file
  size.

Regarding tests, add sanity-sec test_53 to exercise encryption from
clients with different PAGE_SIZE.
The trick to achieve this with AT is to expect the client to have 64KB
PAGE_SIZE, and the servers to have 4KB PAGE_SIZE, and then mount a
client from the MDS node.
This also means code running on server side needs to have client
encryption support enabled, so CentOS/RHEL 8 at least.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: ac5fcdce025b4 ("LU-12275 sec: encryption with different client PAGE_SIZE")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/39315
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c      | 28 +++++++++++-----
 fs/lustre/osc/osc_request.c | 79 +++++++++++++++++++++++++++------------------
 2 files changed, 68 insertions(+), 39 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 02cc2d6..f7f917b 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -444,16 +444,28 @@ static inline int ll_dom_readpage(void *data, struct page *page)
 	kunmap_atomic(kaddr);
 
 	if (inode && IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode)) {
-		if (!llcrypt_has_encryption_key(inode))
+		if (!llcrypt_has_encryption_key(inode)) {
 			CDEBUG(D_SEC, "no enc key for " DFID "\n",
 			       PFID(ll_inode2fid(inode)));
-		/* decrypt only if page is not empty */
-		else if (memcmp(page_address(page),
-				page_address(ZERO_PAGE(0)),
-				PAGE_SIZE) != 0)
-			rc = llcrypt_decrypt_pagecache_blocks(page,
-							      PAGE_SIZE,
-							      0);
+		} else {
+			unsigned int offs = 0;
+
+			while (offs < PAGE_SIZE) {
+				/* decrypt only if page is not empty */
+				if (memcmp(page_address(page) + offs,
+					   page_address(ZERO_PAGE(0)),
+					   LUSTRE_ENCRYPTION_UNIT_SIZE) == 0)
+					break;
+
+				rc = llcrypt_decrypt_pagecache_blocks(page,
+								      LUSTRE_ENCRYPTION_UNIT_SIZE,
+								      0);
+				if (rc)
+					break;
+
+				offs += LUSTRE_ENCRYPTION_UNIT_SIZE;
+			}
+		}
 	}
 	unlock_page(page);
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index bf9ce44..746b695 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1421,8 +1421,12 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			struct page *data_page = NULL;
 			bool retried = false;
 			bool lockedbymyself;
+			u32 nunits = (pg->off & ~PAGE_MASK) + pg->count;
 
 retry_encrypt:
+			if (nunits & ~LUSTRE_ENCRYPTION_MASK)
+				nunits = (nunits & LUSTRE_ENCRYPTION_MASK) +
+					  LUSTRE_ENCRYPTION_UNIT_SIZE;
 			/* The page can already be locked when we arrive here.
 			 * This is possible when cl_page_assume/vvp_page_assume
 			 * is stuck on wait_on_page_writeback with page lock
@@ -1435,7 +1439,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			lockedbymyself = trylock_page(pg->pg);
 			data_page =
 				llcrypt_encrypt_pagecache_blocks(pg->pg,
-								 PAGE_SIZE, 0,
+								 nunits, 0,
 								 GFP_NOFS);
 			if (lockedbymyself)
 				unlock_page(pg->pg);
@@ -1458,24 +1462,29 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 					     oap->oap_obj_off +
 					     oap->oap_page_off;
 			}
-			/* len is forced to PAGE_SIZE, and poff to 0
+			/* len is forced to nunits, and relative offset to 0
 			 * so store the old, clear text info
 			 */
-			pg->bp_count_diff = PAGE_SIZE - pg->count;
-			pg->count = PAGE_SIZE;
+			pg->bp_count_diff = nunits - pg->count;
+			pg->count = nunits;
 			pg->bp_off_diff = pg->off & ~PAGE_MASK;
 			pg->off = pg->off & PAGE_MASK;
 		}
 	} else if (opc == OST_READ && inode && IS_ENCRYPTED(inode)) {
 		for (i = 0; i < page_count; i++) {
 			struct brw_page *pg = pga[i];
-
-			/* count/off are forced to cover the whole page so that
-			 * all encrypted data is stored on the OST, so adjust
-			 * bp_{count,off}_diff for the size of the clear text.
+			u32 nunits = (pg->off & ~PAGE_MASK) + pg->count;
+
+			if (nunits & ~LUSTRE_ENCRYPTION_MASK)
+				nunits = (nunits & LUSTRE_ENCRYPTION_MASK) +
+					  LUSTRE_ENCRYPTION_UNIT_SIZE;
+			/* count/off are forced to cover the whole encryption
+			 * unit size so that all encrypted data is stored on the
+			 * OST, so adjust bp_{count,off}_diff for the size of
+			 * the clear text.
 			 */
-			pg->bp_count_diff = PAGE_SIZE - pg->count;
-			pg->count = PAGE_SIZE;
+			pg->bp_count_diff = nunits - pg->count;
+			pg->count = nunits;
 			pg->bp_off_diff = pg->off & ~PAGE_MASK;
 			pg->off = pg->off & PAGE_MASK;
 		}
@@ -2096,30 +2105,38 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		}
 		for (idx = 0; idx < aa->aa_page_count; idx++) {
 			struct brw_page *pg = aa->aa_ppga[idx];
+			unsigned int offs = 0;
+
+			while (offs < PAGE_SIZE) {
+				/* do not decrypt if page is all 0s */
+				if (memchr_inv(page_address(pg->pg) + offs, 0,
+					       LUSTRE_ENCRYPTION_UNIT_SIZE) == NULL) {
+					/* if page is empty forward info to
+					 * upper layers (ll_io_zero_page) by
+					 * clearing PagePrivate2
+					 */
+					if (!offs)
+						ClearPagePrivate2(pg->pg);
+					break;
+				}
 
-			/* do not decrypt if page is all 0s */
-			if (memchr_inv(page_address(pg->pg), 0,
-				       PAGE_SIZE) == NULL) {
-				/* if page is empty forward info to upper layers
-				 * (ll_io_zero_page) by clearing PagePrivate2
+				/* The page is already locked when we arrive
+				 * here, except when we deal with a twisted
+				 * page for specific Direct IO support, in
+				 * which case PageChecked flag is set on page.
 				 */
-				ClearPagePrivate2(pg->pg);
-				continue;
+				if (PageChecked(pg->pg))
+					lock_page(pg->pg);
+				rc = llcrypt_decrypt_pagecache_blocks(pg->pg,
+								      LUSTRE_ENCRYPTION_UNIT_SIZE,
+								      offs);
+				if (PageChecked(pg->pg))
+					unlock_page(pg->pg);
+				if (rc)
+					goto out;
+
+				offs += LUSTRE_ENCRYPTION_UNIT_SIZE;
 			}
-
-			/* The page is already locked when we arrive here,
-			 * except when we deal with a twisted page for
-			 * specific Direct IO support, in which case
-			 * PageChecked flag is set on page.
-			 */
-			if (PageChecked(pg->pg))
-				lock_page(pg->pg);
-			rc = llcrypt_decrypt_pagecache_blocks(pg->pg,
-							      PAGE_SIZE, 0);
-			if (PageChecked(pg->pg))
-				unlock_page(pg->pg);
-			if (rc)
-				goto out;
 		}
 	}
 
-- 
1.8.3.1
