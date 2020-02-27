From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:36 -0500
Subject: [lustre-devel] [PATCH 528/622] lustre: use simple sleep in some
 cases
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-529-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

To match the OpenSFS branch change schedule_timeout_uninterruptible()
to ssleep(). In mdc_request.c the change to ssleep() lets us remove
a wait queue. In seq_client_alloc_meta() wait 2 seconds before
attempting to run seq_client_rpc() again.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10467
Lustre-commit: 077b35568be5 ("LU-10467 lustre: don't use l_wait_event() for simple sleep.")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35966
Lustre-commit: d0ca764a1a91 ("LU-10467 lustre: don't use l_wait_event() for poll loops.")
Reviewed-on: https://review.whamcloud.com/35968
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fid/fid_request.c | 7 +++++++
 fs/lustre/llite/llite_lib.c | 3 ++-
 fs/lustre/lov/lov_request.c | 4 +++-
 fs/lustre/mdc/mdc_request.c | 5 ++---
 fs/lustre/ptlrpc/events.c   | 7 +++----
 5 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/fid/fid_request.c b/fs/lustre/fid/fid_request.c
index a54d1e5..6cede30 100644
--- a/fs/lustre/fid/fid_request.c
+++ b/fs/lustre/fid/fid_request.c
@@ -40,6 +40,7 @@
 #define DEBUG_SUBSYSTEM S_FID
 
 #include <linux/module.h>
+#include <linux/delay.h>
 
 #include <obd.h>
 #include <obd_class.h>
@@ -155,6 +156,12 @@ static int seq_client_alloc_meta(const struct lu_env *env,
 		 */
 		rc = seq_client_rpc(seq, &seq->lcs_space,
 				    SEQ_ALLOC_META, "meta");
+		if (rc == -EINPROGRESS || rc == -EAGAIN)
+			/* MDT0 is not ready, let's wait for 2
+			 * seconds and retry.
+			 */
+			ssleep(2);
+
 	} while (rc == -EINPROGRESS || rc == -EAGAIN);
 
 	return rc;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 384b55b..7e128f0 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -42,6 +42,7 @@
 #include <linux/statfs.h>
 #include <linux/types.h>
 #include <linux/mm.h>
+#include <linux/delay.h>
 #include <linux/uuid.h>
 #include <linux/random.h>
 #include <linux/security.h>
@@ -2344,7 +2345,7 @@ void ll_umount_begin(struct super_block *sb)
 	 * to decrement mnt_cnt and hope to finish it within 10sec.
 	 */
 	while (cnt < 10 && !may_umount(sbi->ll_mnt.mnt)) {
-		schedule_timeout_uninterruptible(HZ);
+		ssleep(1);
 		cnt++;
 	}
 
diff --git a/fs/lustre/lov/lov_request.c b/fs/lustre/lov/lov_request.c
index added19..d263cec 100644
--- a/fs/lustre/lov/lov_request.c
+++ b/fs/lustre/lov/lov_request.c
@@ -33,6 +33,8 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
+#include <linux/delay.h>
+
 #include <obd_class.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include "lov_internal.h"
@@ -130,7 +132,7 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 	mutex_unlock(&lov->lov_lock);
 
 	while (cnt < obd_timeout && !lov_check_set(lov, ost_idx)) {
-		schedule_timeout_uninterruptible(HZ);
+		ssleep(1);
 		cnt++;
 	}
 	if (tgt->ltd_active)
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 287013f..54f6d15 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -37,6 +37,7 @@
 #include <linux/pagemap.h>
 #include <linux/init.h>
 #include <linux/utsname.h>
+#include <linux/delay.h>
 #include <linux/file.h>
 #include <linux/kthread.h>
 #include <linux/prefetch.h>
@@ -1043,13 +1044,11 @@ static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
 {
 	struct ptlrpc_bulk_desc *desc;
 	struct ptlrpc_request *req;
-	wait_queue_head_t waitq;
 	int resends = 0;
 	int rc;
 	int i;
 
 	*request = NULL;
-	init_waitqueue_head(&waitq);
 
 restart_bulk:
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_READPAGE);
@@ -1093,7 +1092,7 @@ static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
 			       exp->exp_obd->obd_name, -EIO);
 			return -EIO;
 		}
-		wait_event_idle_timeout(waitq, 0, resends * HZ);
+		ssleep(resends);
 
 		goto restart_bulk;
 	}
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index e6a49db..ce13aa6 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -34,9 +34,8 @@
 #define DEBUG_SUBSYSTEM S_RPC
 
 #include <linux/libcfs/libcfs.h>
-# ifdef __mips64__
-#  include <linux/kernel.h>
-# endif
+#include <linux/kernel.h>
+#include <linux/delay.h>
 
 #include <obd_class.h>
 #include <lustre_net.h>
@@ -522,7 +521,7 @@ static void ptlrpc_ni_fini(void)
 			if (retries != 0)
 				CWARN("Event queue still busy\n");
 
-			schedule_timeout_uninterruptible(2 * HZ);
+			ssleep(2);
 			break;
 		}
 	}
-- 
1.8.3.1
