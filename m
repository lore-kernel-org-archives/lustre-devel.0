From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Fri,  7 Apr 2017 17:57:04 -0700
Subject: [lustre-devel] [PATCH 06/12] audit: Use timespec64 to represent
	audit timestamps
In-Reply-To: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <1491613030-11599-7-git-send-email-deepa.kernel@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: yuchao0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, clm-b10kYP2dOMg@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, dushistov-JGs/UdohzUI@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, dsterba-IBi9RG/b67k@public.gmane.org, jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbacik-b10kYP2dOMg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-btrfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

struct timespec is not y2038 safe.
Audit timestamps are recorded in string format into
an audit buffer for a given context.
These mark the entry timestamps for the syscalls.
Use y2038 safe struct timespec64 to represent the times.
The log strings can handle this transition as strings can
hold upto 1024 characters.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Paul Moore <paul@paul-moore.com>
Acked-by: Richard Guy Briggs <rgb@redhat.com>
---
 include/linux/audit.h |  4 ++--
 kernel/audit.c        | 10 +++++-----
 kernel/audit.h        |  2 +-
 kernel/auditsc.c      |  6 +++---
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 6fdfefc..f830508 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -332,7 +332,7 @@ static inline void audit_ptrace(struct task_struct *t)
 				/* Private API (for audit.c only) */
 extern unsigned int audit_serial(void);
 extern int auditsc_get_stamp(struct audit_context *ctx,
-			      struct timespec *t, unsigned int *serial);
+			      struct timespec64 *t, unsigned int *serial);
 extern int audit_set_loginuid(kuid_t loginuid);
 
 static inline kuid_t audit_get_loginuid(struct task_struct *tsk)
@@ -511,7 +511,7 @@ static inline void __audit_seccomp(unsigned long syscall, long signr, int code)
 static inline void audit_seccomp(unsigned long syscall, long signr, int code)
 { }
 static inline int auditsc_get_stamp(struct audit_context *ctx,
-			      struct timespec *t, unsigned int *serial)
+			      struct timespec64 *t, unsigned int *serial)
 {
 	return 0;
 }
diff --git a/kernel/audit.c b/kernel/audit.c
index 2f4964c..fcbf377 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1625,10 +1625,10 @@ unsigned int audit_serial(void)
 }
 
 static inline void audit_get_stamp(struct audit_context *ctx,
-				   struct timespec *t, unsigned int *serial)
+				   struct timespec64 *t, unsigned int *serial)
 {
 	if (!ctx || !auditsc_get_stamp(ctx, t, serial)) {
-		*t = CURRENT_TIME;
+		ktime_get_real_ts64(t);
 		*serial = audit_serial();
 	}
 }
@@ -1652,7 +1652,7 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 				     int type)
 {
 	struct audit_buffer *ab;
-	struct timespec t;
+	struct timespec64 t;
 	unsigned int uninitialized_var(serial);
 
 	if (audit_initialized != AUDIT_INITIALIZED)
@@ -1705,8 +1705,8 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 	}
 
 	audit_get_stamp(ab->ctx, &t, &serial);
-	audit_log_format(ab, "audit(%lu.%03lu:%u): ",
-			 t.tv_sec, t.tv_nsec/1000000, serial);
+	audit_log_format(ab, "audit(%llu.%03lu:%u): ",
+			 (unsigned long long)t.tv_sec, t.tv_nsec/1000000, serial);
 
 	return ab;
 }
diff --git a/kernel/audit.h b/kernel/audit.h
index 0f1cf6d..cdf96f4 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -112,7 +112,7 @@ struct audit_context {
 	enum audit_state    state, current_state;
 	unsigned int	    serial;     /* serial number for record */
 	int		    major;      /* syscall number */
-	struct timespec	    ctime;      /* time of syscall entry */
+	struct timespec64   ctime;      /* time of syscall entry */
 	unsigned long	    argv[4];    /* syscall arguments */
 	long		    return_code;/* syscall return code */
 	u64		    prio;
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index e59ffc7..a2d9217 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1532,7 +1532,7 @@ void __audit_syscall_entry(int major, unsigned long a1, unsigned long a2,
 		return;
 
 	context->serial     = 0;
-	context->ctime      = CURRENT_TIME;
+	ktime_get_real_ts64(&context->ctime);
 	context->in_syscall = 1;
 	context->current_state  = state;
 	context->ppid       = 0;
@@ -1941,13 +1941,13 @@ EXPORT_SYMBOL_GPL(__audit_inode_child);
 /**
  * auditsc_get_stamp - get local copies of audit_context values
  * @ctx: audit_context for the task
- * @t: timespec to store time recorded in the audit_context
+ * @t: timespec64 to store time recorded in the audit_context
  * @serial: serial value that is recorded in the audit_context
  *
  * Also sets the context as auditable.
  */
 int auditsc_get_stamp(struct audit_context *ctx,
-		       struct timespec *t, unsigned int *serial)
+		       struct timespec64 *t, unsigned int *serial)
 {
 	if (!ctx->in_syscall)
 		return 0;
-- 
2.7.4
