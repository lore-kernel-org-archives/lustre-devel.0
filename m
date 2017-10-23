From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Oct 2017 11:53:49 +1100
Subject: [lustre-devel] [PATCH 8/9] staging: lustre: ldlm: remove
 unnecessary 'ownlocks' variable.
In-Reply-To: <150871988297.3340.4522589460981284121.stgit@noble>
References: <150871988297.3340.4522589460981284121.stgit@noble>
Message-ID: <150872002983.3340.10585764760968162389.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org

Now that the code has been simplified, 'ownlocks' is not
necessary.

The loop which sets it exits with 'lock' having the same value as
'ownlocks', or pointing to the head of the list if ownlocks is NULL.

The current code then tests ownlocks and sets 'lock' to exactly the
value that it currently has.

So discard 'ownlocks'.

Also remove unnecessary initialization of 'lock'.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |   15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 0bf6dce1c5b1..774d8667769a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -115,8 +115,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 	struct ldlm_resource *res = req->l_resource;
 	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
 	struct ldlm_lock *tmp;
-	struct ldlm_lock *ownlocks = NULL;
-	struct ldlm_lock *lock = NULL;
+	struct ldlm_lock *lock;
 	struct ldlm_lock *new = req;
 	struct ldlm_lock *new2 = NULL;
 	enum ldlm_mode mode = req->l_req_mode;
@@ -140,22 +139,14 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 	/* This loop determines where this processes locks start
 	 * in the resource lr_granted list.
 	 */
-	list_for_each_entry(lock, &res->lr_granted, l_res_link) {
-		if (ldlm_same_flock_owner(lock, req)) {
-			ownlocks = lock;
+	list_for_each_entry(lock, &res->lr_granted, l_res_link)
+		if (ldlm_same_flock_owner(lock, req))
 			break;
-		}
-	}
 
 	/* Scan the locks owned by this process to find the insertion point
 	 * (as locks are ordered), and to handle overlaps.
 	 * We may have to merge or split existing locks.
 	 */
-	if (ownlocks)
-		lock = ownlocks;
-	else
-		lock = list_entry(&res->lr_granted,
-				  struct ldlm_lock, l_res_link);
 	list_for_each_entry_safe_from(lock, tmp, &res->lr_granted, l_res_link) {
 
 		if (!ldlm_same_flock_owner(lock, new))
