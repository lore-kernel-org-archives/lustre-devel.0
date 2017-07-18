From: NeilBrown <neilb@suse.com>
Date: Wed, 19 Jul 2017 09:26:47 +1000
Subject: [lustre-devel] [PATCH 05/12] staging: lustre: ldlm: remove unused
 'work_list' arg from ldlm_process_flock_lock()
In-Reply-To: <150041997277.20736.17112251996623587423.stgit@noble>
References: <150041997277.20736.17112251996623587423.stgit@noble>
Message-ID: <150042040750.20736.7704797489296782229.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

'work_list' is only set to NULL, and is never used.
So discard it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 8ba3eaf49c65..dce81fbf3049 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -123,8 +123,7 @@ ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
  *
  */
 static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
-				   enum ldlm_error *err,
-				   struct list_head *work_list)
+				   enum ldlm_error *err)
 {
 	struct ldlm_resource *res = req->l_resource;
 	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
@@ -594,7 +593,7 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 		/* We need to reprocess the lock to do merges or splits
 		 * with existing locks owned by this process.
 		 */
-		ldlm_process_flock_lock(lock, &noreproc, &err, NULL);
+		ldlm_process_flock_lock(lock, &noreproc, &err);
 	}
 	unlock_res_and_lock(lock);
 	return rc;
