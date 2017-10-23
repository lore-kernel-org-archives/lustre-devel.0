From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Oct 2017 11:53:49 +1100
Subject: [lustre-devel] [PATCH 2/9] staging: lustre: ldlm: remove unused
 'work_list' arg from ldlm_process_flock_lock()
In-Reply-To: <150871988297.3340.4522589460981284121.stgit@noble>
References: <150871988297.3340.4522589460981284121.stgit@noble>
Message-ID: <150872002962.3340.16967380600702796184.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org

'work_list' is only set to NULL, and is never used.
So discard it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index f719dc05e1ea..766653b4d8a5 100644
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
