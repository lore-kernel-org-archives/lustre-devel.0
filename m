From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:09 -0500
Subject: [lustre-devel] [PATCH 201/622] lustre: sec: create new function
 sptlrpc_get_sepol()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-202-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Create new function sptlrpc_get_sepol() in ptlrpc/sec.c to compute
SELinux policy info, by calling new userland command l_getsepol.

The SELinux policy info syntax is the following:
<mode>:<name>:<version>:<hash>
where:
- <mode> is a digit telling if SELinux is in Permissive mode (0)
  or Enforcing mode (1)
- <name> is the name of the SELinux policy
- <version> is the version of the SELinux policy
- <hash> is the computed hash of the binary representation of the
  policy, as exported in /etc/selinux/<name>/policy/policy.<version>

Userland command l_getsepol can be called on the command line by a
security administrator to get SELinux status information to store into
'sepol' field of nodemap.

SELinux status information is reported by Lustre client only if
new 'send_sepol' ptlrpc kernel module's parameter is not zero, and
SELinux is enabled on the client.
'send_sepol' accepts various values:
- 0: do not send SELinux policy info;
- -1: send SELinux policy info for every request;
- N > 0: only send SELinux policy info every N seconds. Use max value
  2^31-1 (signed int on 32 bits) to make sure SELinux policy info is
  only checked at mount time.
Independently from 'send_sepol' value, SELinux policy info has an
associated mtime. l_getsepol checks mtime and recalculates whole
SELinux policy info (including SHA) only if mtime changed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8955
Lustre-commit: c61168239eff ("LU-8955 sec: create new function sptlrpc_get_sepol()")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/24421
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h          |   7 ++
 fs/lustre/include/lustre_sec.h          |  12 +++
 fs/lustre/ptlrpc/sec.c                  | 125 ++++++++++++++++++++++++++++++++
 fs/lustre/ptlrpc/sec_lproc.c            |  74 +++++++++++++++++++
 include/uapi/linux/lustre/lustre_idl.h  |  13 ++++
 include/uapi/linux/lustre/lustre_user.h |   9 +++
 6 files changed, 240 insertions(+)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 81a6ac9..36de665 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -845,6 +845,13 @@ struct ptlrpc_request {
 	/** description of flavors for client & server */
 	struct sptlrpc_flavor		rq_flvr;
 
+	/**
+	 * SELinux policy info at the time of the request
+	 * sepol string format is:
+	 * <mode>:<policy name>:<policy version>:<policy hash>
+	 */
+	char rq_sepol[LUSTRE_NODEMAP_SEPOL_LENGTH + 1];
+
 	/* client/server security flags */
 	unsigned int
 				 rq_ctx_init:1,      /* context initiation */
diff --git a/fs/lustre/include/lustre_sec.h b/fs/lustre/include/lustre_sec.h
index 99702fd..00710d6 100644
--- a/fs/lustre/include/lustre_sec.h
+++ b/fs/lustre/include/lustre_sec.h
@@ -792,6 +792,17 @@ struct ptlrpc_sec {
 	/** owning import */
 	struct obd_import	       *ps_import;
 	spinlock_t			ps_lock;
+	/** mtime of SELinux policy file */
+	time_t				ps_sepol_mtime;
+	/** next check time of SELinux policy file */
+	ktime_t				ps_sepol_checknext;
+	/**
+	 * SELinux policy info
+	 * sepol string format is:
+	 * <mode>:<policy name>:<policy version>:<policy hash>
+	 */
+	char				ps_sepol[LUSTRE_NODEMAP_SEPOL_LENGTH
+						 + 1];
 
 	/*
 	 * garbage collection
@@ -987,6 +998,7 @@ int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 void sptlrpc_cli_finish_early_reply(struct ptlrpc_request *early_req);
 
 void sptlrpc_request_out_callback(struct ptlrpc_request *req);
+int sptlrpc_get_sepol(struct ptlrpc_request *req);
 
 /*
  * exported higher interface of import & request
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index 54ca97c..789b5cb 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -53,6 +53,10 @@
 
 #include "ptlrpc_internal.h"
 
+static int send_sepol;
+module_param(send_sepol, int, 0644);
+MODULE_PARM_DESC(send_sepol, "Client sends SELinux policy status");
+
 /***********************************************
  * policy registers			    *
  ***********************************************/
@@ -1692,6 +1696,127 @@ static int sptlrpc_svc_install_rvs_ctx(struct obd_import *imp,
 	return policy->sp_sops->install_rctx(imp, ctx);
 }
 
+#ifdef CONFIG_SECURITY_SELINUX
+/* Get SELinux policy info from userspace */
+static int sepol_helper(struct obd_import *imp)
+{
+	char mtime_str[21] = { 0 }, mode_str[2] = { 0 };
+	char *argv[] = {
+		[0] = "/usr/sbin/l_getsepol",
+		[1] = "-o",
+		[2] = NULL,	    /* obd type */
+		[3] = "-n",
+		[4] = NULL,	    /* obd name */
+		[5] = "-t",
+		[6] = mtime_str,    /* policy mtime */
+		[7] = "-m",
+		[8] = mode_str,	    /* enforcing mode */
+		[9] = NULL
+	};
+	static char *envp[] = {
+		[0] = "HOME=/",
+		[1] = "PATH=/sbin:/usr/sbin",
+		[2] = NULL
+	};
+	signed short ret;
+	int rc = 0;
+
+	if (!imp || !imp->imp_obd ||
+	    !imp->imp_obd->obd_type) {
+		rc = -EINVAL;
+	} else {
+		argv[2] = (char *)imp->imp_obd->obd_type->typ_name;
+		argv[4] = imp->imp_obd->obd_name;
+		spin_lock(&imp->imp_sec->ps_lock);
+		if (imp->imp_sec->ps_sepol_mtime == 0 &&
+		    imp->imp_sec->ps_sepol[0] == '\0') {
+			/* ps_sepol has not been initialized */
+			argv[5] = NULL;
+			argv[7] = NULL;
+		} else {
+			snprintf(mtime_str, sizeof(mtime_str), "%lu",
+				 imp->imp_sec->ps_sepol_mtime);
+			mode_str[0] = imp->imp_sec->ps_sepol[0];
+		}
+		spin_unlock(&imp->imp_sec->ps_lock);
+		ret = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
+		rc = ret>>8;
+	}
+
+	return rc;
+}
+#endif
+
+static inline int sptlrpc_sepol_needs_check(struct ptlrpc_sec *imp_sec)
+{
+	ktime_t checknext;
+
+	if (send_sepol == 0)
+		return 0;
+
+	if (send_sepol == -1)
+		/* send_sepol == -1 means fetch sepol status every time */
+		return 1;
+
+	spin_lock(&imp_sec->ps_lock);
+	checknext = imp_sec->ps_sepol_checknext;
+	spin_unlock(&imp_sec->ps_lock);
+
+	/* next check is too far in time, please update */
+	if (ktime_after(checknext,
+			ktime_add(ktime_get(), ktime_set(send_sepol, 0))))
+		goto setnext;
+
+	if (ktime_before(ktime_get(), checknext))
+		/* too early to fetch sepol status */
+		return 0;
+
+setnext:
+	/* define new sepol_checknext time */
+	spin_lock(&imp_sec->ps_lock);
+	imp_sec->ps_sepol_checknext = ktime_add(ktime_get(),
+						ktime_set(send_sepol, 0));
+	spin_unlock(&imp_sec->ps_lock);
+
+	return 1;
+}
+
+int sptlrpc_get_sepol(struct ptlrpc_request *req)
+{
+#ifndef CONFIG_SECURITY_SELINUX
+	(req->rq_sepol)[0] = '\0';
+
+	if (unlikely(send_sepol != 0))
+		CDEBUG(D_SEC,
+		       "Client cannot report SELinux status, it was not built against libselinux.\n");
+	return 0;
+#else
+	struct ptlrpc_sec *imp_sec = req->rq_import->imp_sec;
+	int rc = 0;
+
+	(req->rq_sepol)[0] = '\0';
+
+	if (send_sepol == 0)
+		return 0;
+
+	if (!imp_sec)
+		return -EINVAL;
+
+	/* Retrieve SELinux status info */
+	if (sptlrpc_sepol_needs_check(imp_sec))
+		rc = sepol_helper(req->rq_import);
+	if (likely(rc == 0)) {
+		spin_lock(&imp_sec->ps_lock);
+		memcpy(req->rq_sepol, imp_sec->ps_sepol,
+		       sizeof(req->rq_sepol));
+		spin_unlock(&imp_sec->ps_lock);
+	}
+
+	return rc;
+#endif
+}
+EXPORT_SYMBOL(sptlrpc_get_sepol);
+
 /****************************************
  * server side security		 *
  ****************************************/
diff --git a/fs/lustre/ptlrpc/sec_lproc.c b/fs/lustre/ptlrpc/sec_lproc.c
index df7c667..04e421d 100644
--- a/fs/lustre/ptlrpc/sec_lproc.c
+++ b/fs/lustre/ptlrpc/sec_lproc.c
@@ -131,6 +131,78 @@ static int sptlrpc_ctxs_lprocfs_seq_show(struct seq_file *seq, void *v)
 
 LPROC_SEQ_FOPS_RO(sptlrpc_ctxs_lprocfs);
 
+static ssize_t
+lprocfs_wr_sptlrpc_sepol(struct file *file, const char __user *buffer,
+			 size_t count, void *data)
+{
+	struct seq_file	*seq = file->private_data;
+	struct obd_device *dev = seq->private;
+	struct client_obd *cli = &dev->u.cli;
+	struct obd_import *imp = cli->cl_import;
+	struct sepol_downcall_data *param;
+	int size = sizeof(*param);
+	int rc = 0;
+
+	if (count < size) {
+		CERROR("%s: invalid data count = %lu, size = %d\n",
+		       dev->obd_name, (unsigned long) count, size);
+		return -EINVAL;
+	}
+
+	param = kzalloc(size, GFP_KERNEL);
+	if (!param)
+		return -ENOMEM;
+
+	if (copy_from_user(param, buffer, size)) {
+		CERROR("%s: bad sepol data\n", dev->obd_name);
+		rc = -EFAULT;
+		goto out;
+	}
+
+	if (param->sdd_magic != SEPOL_DOWNCALL_MAGIC) {
+		CERROR("%s: sepol downcall bad params\n",
+		       dev->obd_name);
+		rc = -EINVAL;
+		goto out;
+	}
+
+	if (param->sdd_sepol_len == 0 ||
+	    param->sdd_sepol_len >= sizeof(imp->imp_sec->ps_sepol)) {
+		CERROR("%s: invalid sepol data returned\n",
+		       dev->obd_name);
+		rc = -EINVAL;
+		goto out;
+	}
+	rc = param->sdd_sepol_len; /* save sdd_sepol_len */
+	kfree(param);
+	size = offsetof(struct sepol_downcall_data,
+			sdd_sepol[rc]);
+
+	/* alloc again with real size */
+	rc = 0;
+	param = kzalloc(size, GFP_KERNEL);
+	if (!param)
+		return -ENOMEM;
+
+	if (copy_from_user(param, buffer, size)) {
+		CERROR("%s: bad sepol data\n", dev->obd_name);
+		rc = -EFAULT;
+		goto out;
+	}
+
+	spin_lock(&imp->imp_sec->ps_lock);
+	snprintf(imp->imp_sec->ps_sepol, param->sdd_sepol_len + 1, "%s",
+		 param->sdd_sepol);
+	imp->imp_sec->ps_sepol_mtime = param->sdd_sepol_mtime;
+	spin_unlock(&imp->imp_sec->ps_lock);
+
+out:
+	kfree(param);
+
+	return rc ? rc : count;
+}
+LPROC_SEQ_FOPS_WR_ONLY(srpc, sptlrpc_sepol);
+
 int sptlrpc_lprocfs_cliobd_attach(struct obd_device *dev)
 {
 	if (strcmp(dev->obd_type->typ_name, LUSTRE_OSC_NAME) != 0 &&
@@ -145,6 +217,8 @@ int sptlrpc_lprocfs_cliobd_attach(struct obd_device *dev)
 			    &sptlrpc_info_lprocfs_fops);
 	debugfs_create_file("srpc_contexts", 0444, dev->obd_debugfs_entry, dev,
 			    &sptlrpc_ctxs_lprocfs_fops);
+	debugfs_create_file("srpc_sepol", 0200, dev->obd_debugfs_entry, dev,
+			    &srpc_sptlrpc_sepol_fops);
 
 	return 0;
 }
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index f723d7b..77b9539 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2936,6 +2936,19 @@ struct close_data {
 	};
 };
 
+/* sepol string format is:
+ * <1-digit for SELinux status>:<policy name>:<policy version>:<policy hash>
+ */
+/* Max length of the sepol string
+ * Should be large enough to contain a sha512sum of the policy
+ */
+#define SELINUX_MODE_LEN 1
+#define SELINUX_POLICY_VER_LEN 3 /* 3 chars to leave room for the future */
+#define SELINUX_POLICY_HASH_LEN 64
+#define LUSTRE_NODEMAP_SEPOL_LENGTH (SELINUX_MODE_LEN + NAME_MAX + \
+				     SELINUX_POLICY_VER_LEN + \
+				     SELINUX_POLICY_HASH_LEN + 3)
+
 /*
  * This is the lu_ladvise struct which goes out on the wire.
  * Corresponds to the userspace arg llapi_lu_ladvise.
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 649aeeb..c1e9dca 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -798,6 +798,7 @@ static inline char *qtype_name(int qtype)
 }
 
 #define IDENTITY_DOWNCALL_MAGIC 0x6d6dd629
+#define SEPOL_DOWNCALL_MAGIC 0x8b8bb842
 
 /* permission */
 #define N_PERMS_MAX	64
@@ -819,6 +820,14 @@ struct identity_downcall_data {
 	__u32			    idd_groups[0];
 };
 
+struct sepol_downcall_data {
+	__u32		sdd_magic;
+	time_t		sdd_sepol_mtime;
+	__u16		sdd_sepol_len;
+	char		sdd_sepol[0];
+};
+
+
 /* lustre volatile file support
  * file name header: ".^L^S^T^R:volatile"
  */
-- 
1.8.3.1
