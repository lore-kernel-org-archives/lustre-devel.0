From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Oct 2017 15:59:27 +1100
Subject: [lustre-devel] [PATCH 04/10] staging: lustre: ldlm: use
 list_for_each_entry in ldlm_lock.c
In-Reply-To: <150933945578.22133.8029060522107378499.stgit@noble>
References: <150933945578.22133.8029060522107378499.stgit@noble>
Message-ID: <150933956714.22133.9335034661380882104.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

This makes some slightly-confusing code a bit clearer, and
avoids the need for 'tmp'.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index ed061cc46986..036a509eb515 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -885,17 +885,15 @@ static void search_granted_lock(struct list_head *queue,
 				struct ldlm_lock *req,
 				struct sl_insert_point *prev)
 {
-	struct list_head *tmp;
 	struct ldlm_lock *lock, *mode_end, *policy_end;
 
-	list_for_each(tmp, queue) {
-		lock = list_entry(tmp, struct ldlm_lock, l_res_link);
+	list_for_each_entry(lock, queue, l_res_link) {
 
 		mode_end = list_prev_entry(lock, l_sl_mode);
 
 		if (lock->l_req_mode != req->l_req_mode) {
 			/* jump to last lock of mode group */
-			tmp = &mode_end->l_res_link;
+			lock = mode_end;
 			continue;
 		}
 
@@ -932,9 +930,7 @@ static void search_granted_lock(struct list_head *queue,
 					break;
 
 				/* go to next policy group within mode group */
-				tmp = policy_end->l_res_link.next;
-				lock = list_entry(tmp, struct ldlm_lock,
-						  l_res_link);
+				lock = list_next_entry(policy_end, l_res_link);
 			}  /* loop over policy groups within the mode group */
 
 			/* insert point is last lock of the mode group,
