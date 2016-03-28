From: James Simmons <jsimmons@infradead.org>
Date: Sun, 27 Mar 2016 20:26:22 -0400
Subject: [lustre-devel] [PATCH 2/9] staging: lustre: libcfs: remove
	cfs_signal_pending wrapper
In-Reply-To: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
References: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459124789-20758-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Use signal_pending() directly instead of a one line function
wrapper.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13874
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 -
 .../staging/lustre/lnet/libcfs/linux/linux-prim.c  |    7 -------
 drivers/staging/lustre/lustre/include/lustre_lib.h |    2 +-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    6 +++---
 5 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 332394c..9158c61 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -66,7 +66,6 @@ sigset_t cfs_block_allsigs(void);
 sigset_t cfs_block_sigs(unsigned long sigs);
 sigset_t cfs_block_sigsinv(unsigned long sigs);
 void cfs_restore_sigs(sigset_t);
-int cfs_signal_pending(void);
 void cfs_clear_sigpending(void);
 
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
index 8908446..7e5ef0a 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
@@ -128,13 +128,6 @@ cfs_restore_sigs(sigset_t old)
 }
 EXPORT_SYMBOL(cfs_restore_sigs);
 
-int
-cfs_signal_pending(void)
-{
-	return signal_pending(current);
-}
-EXPORT_SYMBOL(cfs_signal_pending);
-
 void
 cfs_clear_sigpending(void)
 {
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index f2223d5..c5713d7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -578,7 +578,7 @@ do {									   \
 									       \
 		if (condition)						 \
 			break;						 \
-		if (cfs_signal_pending()) {				    \
+		if (signal_pending(current)) {				    \
 			if (info->lwi_on_signal &&		     \
 			    (__timeout == 0 || __allow_intr)) {		\
 				if (info->lwi_on_signal != LWI_ON_SIGNAL_NOOP) \
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index aec644e..f952c1c 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -951,7 +951,7 @@ int cl_lock_state_wait(const struct lu_env *env, struct cl_lock *lock)
 		result = -ERESTARTSYS;
 		if (likely(!OBD_FAIL_CHECK(OBD_FAIL_LOCK_STATE_WAIT_INTR))) {
 			schedule();
-			if (!cfs_signal_pending())
+			if (!signal_pending(current))
 				result = 0;
 		}
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 1b7673e..32a7c87 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2087,7 +2087,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 		CDEBUG(D_RPCTRACE, "set %p going to sleep for %d seconds\n",
 		       set, timeout);
 
-		if (timeout == 0 && !cfs_signal_pending())
+		if (timeout == 0 && !signal_pending(current))
 			/*
 			 * No requests are in-flight (ether timed out
 			 * or delayed), so we can allow interrupts.
@@ -2114,7 +2114,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 		 * it being ignored forever
 		 */
 		if (rc == -ETIMEDOUT && !lwi.lwi_allow_intr &&
-		    cfs_signal_pending()) {
+		    signal_pending(current)) {
 			sigset_t blocked_sigs =
 					   cfs_block_sigsinv(LUSTRE_FATAL_SIGS);
 
@@ -2124,7 +2124,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 			 * important signals since ptlrpc set is not easily
 			 * reentrant from userspace again
 			 */
-			if (cfs_signal_pending())
+			if (signal_pending(current))
 				ptlrpc_interrupted_set(set);
 			cfs_restore_sigs(blocked_sigs);
 		}
-- 
1.7.1
