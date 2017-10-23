From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Oct 2017 11:53:49 +1100
Subject: [lustre-devel] [PATCH 1/9] staging: lustre: ldlm: remove
 'first_enq' arg from ldlm_process_flock_lock()
In-Reply-To: <150871988297.3340.4522589460981284121.stgit@noble>
References: <150871988297.3340.4522589460981284121.stgit@noble>
Message-ID: <150872002958.3340.14294625301256962751.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org

it is only ever set to '1', so we can just assume that and remove the code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index cb826e9e840e..f719dc05e1ea 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -121,15 +121,9 @@ ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
  * It is also responsible for splitting a lock if a portion of the lock
  * is released.
  *
- * If \a first_enq is 0 (ie, called from ldlm_reprocess_queue):
- *   - blocking ASTs have already been sent
- *
- * If \a first_enq is 1 (ie, called from ldlm_lock_enqueue):
- *   - blocking ASTs have not been sent yet, so list of conflicting locks
- *     would be collected and ASTs sent.
  */
 static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
-				   int first_enq, enum ldlm_error *err,
+				   enum ldlm_error *err,
 				   struct list_head *work_list)
 {
 	struct ldlm_resource *res = req->l_resource;
@@ -197,11 +191,6 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
 			if (!ldlm_flocks_overlap(lock, req))
 				continue;
 
-			if (!first_enq) {
-				reprocess_failed = 1;
-				continue;
-			}
-
 			if (*flags & LDLM_FL_BLOCK_NOWAIT) {
 				ldlm_flock_destroy(req, mode, *flags);
 				*err = -EAGAIN;
@@ -605,7 +594,7 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 		/* We need to reprocess the lock to do merges or splits
 		 * with existing locks owned by this process.
 		 */
-		ldlm_process_flock_lock(lock, &noreproc, 1, &err, NULL);
+		ldlm_process_flock_lock(lock, &noreproc, &err, NULL);
 	}
 	unlock_res_and_lock(lock);
 	return rc;
