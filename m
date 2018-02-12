From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 08:09:25 +1100
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: fix inverted test on
 strcmp
In-Reply-To: <151846966702.17168.15765227765350491300.stgit@noble>
References: <151846966702.17168.15765227765350491300.stgit@noble>
Message-ID: <151846976573.17168.10557259719846165376.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This code tests various fields to see if they are different, except
for one where there test is if they are the same.
This is clearly wrong for a function that is tesding for equality.

So change "!strcmp()" which I always find hard to read, to
"strcmp() != 0" which obviously means that the strings are not equal.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_lmv.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index f4298e5f7543..080ec1f8e19f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -63,7 +63,7 @@ lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
 	    lsm1->lsm_md_master_mdt_index != lsm2->lsm_md_master_mdt_index ||
 	    lsm1->lsm_md_hash_type != lsm2->lsm_md_hash_type ||
 	    lsm1->lsm_md_layout_version != lsm2->lsm_md_layout_version ||
-	    !strcmp(lsm1->lsm_md_pool_name, lsm2->lsm_md_pool_name))
+	    strcmp(lsm1->lsm_md_pool_name, lsm2->lsm_md_pool_name) != 0)
 		return false;
 
 	for (idx = 0; idx < lsm1->lsm_md_stripe_count; idx++) {
