From: James Simmons <jsimmons@infradead.org>
Date: Sun, 27 Mar 2016 20:26:28 -0400
Subject: [lustre-devel] [PATCH 8/9] staging: lustre: libcfs: add
	CFS_FAULT_CHECK()
In-Reply-To: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
References: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459124789-20758-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, "John L. Hammond" <john.hammond@intel.com>

Add the macro CFS_FAULT_CHECK() which behaves like CFS_FAIL_CHECK()
except that any site may be matched by setting CFS_FAULT (0x02000000)
in cfs_fail_loc. Add cfs_fail_err for use as a return value with
CFS_FAULT_CHECK().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5409
Reviewed-on: http://review.whamcloud.com/11263
Reviewed-by: Robert Read <robert.read@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_fail.h      |   15 ++++++++++++---
 drivers/staging/lustre/lnet/libcfs/fail.c          |    3 +++
 drivers/staging/lustre/lnet/libcfs/module.c        |    7 +++++++
 3 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index aa69c6a..2e008bf 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -38,6 +38,7 @@
 
 extern unsigned long cfs_fail_loc;
 extern unsigned int cfs_fail_val;
+extern int cfs_fail_err;
 
 extern wait_queue_head_t cfs_race_waitq;
 extern int cfs_race_state;
@@ -70,9 +71,14 @@ enum {
 #define CFS_FAIL_RAND	0x08000000 /* fail 1/N of the times */
 #define CFS_FAIL_USR1	0x04000000 /* user flag */
 
-#define CFS_FAIL_PRECHECK(id) (cfs_fail_loc &&				\
-			      (cfs_fail_loc & CFS_FAIL_MASK_LOC) ==	   \
-			      ((id) & CFS_FAIL_MASK_LOC))
+#define CFS_FAULT	0x02000000 /* match any CFS_FAULT_CHECK */
+
+static inline bool CFS_FAIL_PRECHECK(__u32 id)
+{
+	return cfs_fail_loc != 0 &&
+	       ((cfs_fail_loc & CFS_FAIL_MASK_LOC) == (id & CFS_FAIL_MASK_LOC) ||
+	        (cfs_fail_loc & id & CFS_FAULT));
+}
 
 static inline int cfs_fail_check_set(__u32 id, __u32 value,
 				     int set, int quiet)
@@ -144,6 +150,9 @@ static inline int cfs_fail_timeout_set(__u32 id, __u32 value, int ms, int set)
 #define CFS_FAIL_TIMEOUT_MS_ORSET(id, value, ms) \
 	cfs_fail_timeout_set(id, value, ms, CFS_FAIL_LOC_ORSET)
 
+#define CFS_FAULT_CHECK(id)			\
+	CFS_FAIL_CHECK(CFS_FAULT | (id))
+
 /* The idea here is to synchronise two threads to force a race. The
  * first thread that calls this with a matching fail_loc is put to
  * sleep. The next thread that calls with the same fail_loc wakes up
diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
index dadaf76..086e690 100644
--- a/drivers/staging/lustre/lnet/libcfs/fail.c
+++ b/drivers/staging/lustre/lnet/libcfs/fail.c
@@ -41,6 +41,9 @@ EXPORT_SYMBOL(cfs_fail_loc);
 unsigned int cfs_fail_val;
 EXPORT_SYMBOL(cfs_fail_val);
 
+int cfs_fail_err;
+EXPORT_SYMBOL(cfs_fail_err);
+
 DECLARE_WAIT_QUEUE_HEAD(cfs_race_waitq);
 EXPORT_SYMBOL(cfs_race_waitq);
 
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 49c2d03..f2d0411 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -425,6 +425,13 @@ static struct ctl_table lnet_table[] = {
 		.proc_handler = &proc_dointvec
 	},
 	{
+		.procname	= "fail_err",
+		.data		= &cfs_fail_err,
+		.maxlen		= sizeof(cfs_fail_err),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 	}
 };
 
-- 
1.7.1
