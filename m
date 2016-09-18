From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:26 -0400
Subject: [lustre-devel] [PATCH 027/124] staging: lustre: ldlm: reconstruct
	proper flags on enqueue resend
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Vitaly Fertman <vitaly_fertman@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Vitaly Fertman <vitaly_fertman@xyratex.com>

otherwise, waiting lock may get granted as no BLOCKED_GRANTED
flag is returned

Signed-off-by: Vitaly Fertman <vitaly_fertman@xyratex.com>
Xyratex-bug-id: MRP-1944
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5496
Reviewed-on: http://review.whamcloud.com/11644
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c   |    3 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c    |    3 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c |    6 ++----
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 78a8450..861f36f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -470,8 +470,7 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 	if (flags & LDLM_FL_FAILED)
 		goto granted;
 
-	if (!(flags & (LDLM_FL_BLOCK_WAIT | LDLM_FL_BLOCK_GRANTED |
-		       LDLM_FL_BLOCK_CONV))) {
+	if (!(flags & LDLM_FL_BLOCKED_MASK)) {
 		if (!data)
 			/* mds granted the lock in the reply */
 			goto granted;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 55b7460..f516106 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1549,8 +1549,7 @@ enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 		 * before we got a chance to actually enqueue it.  We don't
 		 * need to do anything else.
 		 */
-		*flags &= ~(LDLM_FL_BLOCK_GRANTED |
-			    LDLM_FL_BLOCK_CONV | LDLM_FL_BLOCK_WAIT);
+		*flags &= ~LDLM_FL_BLOCKED_MASK;
 		goto out;
 	}
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index f4364f9..cc835cb 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -177,8 +177,7 @@ int ldlm_completion_ast_async(struct ldlm_lock *lock, __u64 flags, void *data)
 		return 0;
 	}
 
-	if (!(flags & (LDLM_FL_BLOCK_WAIT | LDLM_FL_BLOCK_GRANTED |
-		       LDLM_FL_BLOCK_CONV))) {
+	if (!(flags & LDLM_FL_BLOCKED_MASK)) {
 		wake_up(&lock->l_waitq);
 		return ldlm_completion_tail(lock);
 	}
@@ -224,8 +223,7 @@ int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 		goto noreproc;
 	}
 
-	if (!(flags & (LDLM_FL_BLOCK_WAIT | LDLM_FL_BLOCK_GRANTED |
-		       LDLM_FL_BLOCK_CONV))) {
+	if (!(flags & LDLM_FL_BLOCKED_MASK)) {
 		wake_up(&lock->l_waitq);
 		return 0;
 	}
-- 
1.7.1
