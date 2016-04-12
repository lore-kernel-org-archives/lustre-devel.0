From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Apr 2016 16:14:03 -0400
Subject: [lustre-devel] [PATCH v2 03/16] staging: lustre: ldlm: Fix a race
	during FLock handling
In-Reply-To: <1460492056-31792-1-git-send-email-jsimmons@infradead.org>
References: <1460492056-31792-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460492056-31792-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruno Faccini <bruno.faccini@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bruno Faccini <bruno.faccini@intel.com>

Protect against race where lock could have been just destroyed
due to overlap, in ldlm_process_flock_lock().
Easy reproducer is BULL's NFS Locktests in pthread mode.
(http://nfsv4.bullopensource.org/tools/tests/locktest.php)

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1126
Reviewed-on: http://review.whamcloud.com/7134
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 3f97e1c..5102d78 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -520,11 +520,6 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 granted:
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT, 10);
 
-	if (lock->l_flags & LDLM_FL_DESTROYED) {
-		LDLM_DEBUG(lock, "client-side enqueue waking up: destroyed");
-		return 0;
-	}
-
 	if (lock->l_flags & LDLM_FL_FAILED) {
 		LDLM_DEBUG(lock, "client-side enqueue waking up: failed");
 		return -EIO;
@@ -534,6 +529,16 @@ granted:
 
 	lock_res_and_lock(lock);
 
+	/*
+	 * Protect against race where lock could have been just destroyed
+	 * due to overlap in ldlm_process_flock_lock().
+	 */
+	if (lock->l_flags & LDLM_FL_DESTROYED) {
+		unlock_res_and_lock(lock);
+		LDLM_DEBUG(lock, "client-side enqueue waking up: destroyed");
+		return 0;
+	}
+
 	/* ldlm_lock_enqueue() has already placed lock on the granted list. */
 	list_del_init(&lock->l_res_link);
 
-- 
1.7.1
