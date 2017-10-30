From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Oct 2017 15:59:27 +1100
Subject: [lustre-devel] [PATCH 05/10] staging: lustre: ldlm: use
 list_first_entry in ldlm_lockd.c
In-Reply-To: <150933945578.22133.8029060522107378499.stgit@noble>
References: <150933945578.22133.8029060522107378499.stgit@noble>
Message-ID: <150933956718.22133.9494510718272127912.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index e2707336586c..2aaa5e91c66c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -693,13 +693,13 @@ static int ldlm_bl_get_work(struct ldlm_bl_pool *blp,
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
