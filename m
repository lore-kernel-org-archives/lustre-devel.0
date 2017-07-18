From: NeilBrown <neilb@suse.com>
Date: Wed, 19 Jul 2017 09:26:47 +1000
Subject: [lustre-devel] [PATCH 06/12] staging: lustre: ldlm: remove unneeded
 'err' arg to ldlm_process_flock_lock()
In-Reply-To: <150041997277.20736.17112251996623587423.stgit@noble>
References: <150041997277.20736.17112251996623587423.stgit@noble>
Message-ID: <150042040753.20736.10406373852456927974.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This arg is used to return an error code, but the returned code is never
looked at.  So there is no point returning it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index dce81fbf3049..fbb627a2f6c1 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -122,8 +122,7 @@ ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
  * is released.
  *
  */
-static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
-				   enum ldlm_error *err)
+static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags)
 {
 	struct ldlm_resource *res = req->l_resource;
 	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
@@ -145,8 +144,6 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
 	       req->l_policy_data.l_flock.start,
 	       req->l_policy_data.l_flock.end);
 
-	*err = ELDLM_OK;
-
 	/* No blocking ASTs are sent to the clients for
 	 * Posix file & record locks
 	 */
@@ -192,7 +189,6 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
 
 			if (*flags & LDLM_FL_BLOCK_NOWAIT) {
 				ldlm_flock_destroy(req, mode, *flags);
-				*err = -EAGAIN;
 				return LDLM_ITER_STOP;
 			}
 
@@ -330,7 +326,6 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
 			if (IS_ERR(new2)) {
 				ldlm_flock_destroy(req, lock->l_granted_mode,
 						   *flags);
-				*err = PTR_ERR(new2);
 				return LDLM_ITER_STOP;
 			}
 			goto reprocess;
@@ -440,7 +435,6 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 	struct obd_import	      *imp = NULL;
 	struct ldlm_flock_wait_data     fwd;
 	struct l_wait_info	      lwi;
-	enum ldlm_error		    err;
 	int			     rc = 0;
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT2, 4);
@@ -593,7 +587,7 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 		/* We need to reprocess the lock to do merges or splits
 		 * with existing locks owned by this process.
 		 */
-		ldlm_process_flock_lock(lock, &noreproc, &err);
+		ldlm_process_flock_lock(lock, &noreproc);
 	}
 	unlock_res_and_lock(lock);
 	return rc;
