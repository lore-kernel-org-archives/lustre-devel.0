From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:54 +1100
Subject: [lustre-devel] [PATCH 03/12] staging: lustre: ldlm: use
 list_first_entry in ldlm_lockd.c
In-Reply-To: <151313493380.27582.16490205348451477393.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
Message-ID: <151313495486.27582.12193540145417673665.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

This is only a small simplification, but it makes the code
a little clearer.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index ada50b69c5f6..5f6e7c933b81 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -696,13 +696,13 @@ static int ldlm_bl_get_work(struct ldlm_bl_pool *blp,
 	/* process a request from the blp_list at least every blp_num_threads */
 	if (!list_empty(&blp->blp_list) &&
 	    (list_empty(&blp->blp_prio_list) || num_bl == 0))
-		blwi = list_entry(blp->blp_list.next,
-				  struct ldlm_bl_work_item, blwi_entry);
+		blwi = list_first_entry(&blp->blp_list,
+					struct ldlm_bl_work_item, blwi_entry);
 	else
 		if (!list_empty(&blp->blp_prio_list))
-			blwi = list_entry(blp->blp_prio_list.next,
-					  struct ldlm_bl_work_item,
-					  blwi_entry);
+			blwi = list_first_entry(&blp->blp_prio_list,
+						struct ldlm_bl_work_item,
+						blwi_entry);
 
 	if (blwi) {
 		if (++num_bl >= num_th)
