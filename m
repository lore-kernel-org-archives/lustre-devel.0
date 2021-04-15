Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E10EFC43460
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:05 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A0A8E61222
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0A8E61222
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9E48020110B;
	Wed, 14 Apr 2021 21:04:00 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4EDCE32F601
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:54 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 90C84100F35B;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8F95C91884; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:18 -0400
Message-Id: <1618459361-17909-27-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 26/49] lnet: libcfs: don't depend on sysctl
 support for debugfs
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

Since Linux v5.8-rc1~55^2~6 sysctl support routines like
proc_dointvec() expect a pointer to kernel-space, not userspace.

So stop using these function for debugfs files, and instead
provide bespoke functions.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13783
Lustre-commit: d707b390aec5e95a ("LU-13783 libcfs: don't depend on sysctl support for debugfs")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/40832
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs.h |   3 ++
 net/lnet/libcfs/module.c      | 114 +++++++++++++++++++++++++++++++++++++++---
 net/lnet/lnet/router_proc.c   |   2 +-
 3 files changed, 110 insertions(+), 9 deletions(-)

diff --git a/include/linux/libcfs/libcfs.h b/include/linux/libcfs/libcfs.h
index c77e04b..c98d7a1 100644
--- a/include/linux/libcfs/libcfs.h
+++ b/include/linux/libcfs/libcfs.h
@@ -61,6 +61,9 @@ static inline int notifier_from_ioctl_errno(int err)
 void lnet_insert_debugfs(struct ctl_table *table);
 void lnet_remove_debugfs(struct ctl_table *table);
 
+int debugfs_doint(struct ctl_table *table, int write,
+		  void __user *buffer, size_t *lenp, loff_t *ppos);
+
 /*
  * Memory
  */
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index ad6935c..f9cc6df 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -377,13 +377,36 @@ static int libcfs_force_lbug(struct ctl_table *table, int write,
 }
 
 static int proc_fail_loc(struct ctl_table *table, int write,
-			 void __user *buffer,
-			 size_t *lenp, loff_t *ppos)
+			 void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int rc;
 	long old_fail_loc = cfs_fail_loc;
 
-	rc = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+	if (!*lenp || *ppos) {
+		*lenp = 0;
+		return 0;
+	}
+
+	if (write) {
+		char *kbuf = memdup_user_nul(buffer, *lenp);
+
+		if (IS_ERR(kbuf))
+			return PTR_ERR(kbuf);
+		rc = kstrtoul(kbuf, 0, &cfs_fail_loc);
+		kfree(kbuf);
+		*ppos += *lenp;
+	} else {
+		char kbuf[64 / 3 + 3];
+
+		rc = scnprintf(kbuf, sizeof(kbuf), "%lu\n", cfs_fail_loc);
+		if (copy_to_user(buffer, kbuf, rc)) {
+			rc = -EFAULT;
+		} else {
+			*lenp = rc;
+			*ppos += rc;
+		}
+	}
+
 	if (old_fail_loc != cfs_fail_loc) {
 		cfs_race_state = 1;
 		wake_up(&cfs_race_waitq);
@@ -391,6 +414,81 @@ static int proc_fail_loc(struct ctl_table *table, int write,
 	return rc;
 }
 
+int debugfs_doint(struct ctl_table *table, int write,
+		  void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int rc;
+
+	if (!*lenp || *ppos) {
+		*lenp = 0;
+		return 0;
+	}
+
+	if (write) {
+		char *kbuf = memdup_user_nul(buffer, *lenp);
+		int val;
+
+		if (IS_ERR(kbuf))
+			return PTR_ERR(kbuf);
+
+		rc = kstrtoint(kbuf, 0, &val);
+		kfree(kbuf);
+		if (!rc) {
+			if (table->extra1 && val < *(int *)table->extra1)
+				val = *(int *)table->extra1;
+			if (table->extra2 && val > *(int *)table->extra2)
+				val = *(int *)table->extra2;
+			*(int *)table->data = val;
+		}
+		*ppos += *lenp;
+	} else {
+		char kbuf[64 / 3 + 3];
+
+		rc = scnprintf(kbuf, sizeof(kbuf), "%u\n", *(int *)table->data);
+		if (copy_to_user(buffer, kbuf, rc)) {
+			rc = -EFAULT;
+		} else {
+			*lenp = rc;
+			*ppos += rc;
+		}
+	}
+
+	return rc;
+}
+EXPORT_SYMBOL(debugfs_doint);
+
+static int debugfs_dostring(struct ctl_table *table, int write,
+			    void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int len = *lenp;
+	char *kbuf = table->data;
+
+	if (!len || *ppos) {
+		*lenp = 0;
+		return 0;
+	}
+	if (len > table->maxlen)
+		len = table->maxlen;
+	if (write) {
+		if (copy_from_user(kbuf, buffer, len))
+			return -EFAULT;
+		memset(kbuf + len, 0, table->maxlen - len);
+		*ppos = *lenp;
+	} else {
+		len = strnlen(kbuf, len);
+		if (copy_to_user(buffer, kbuf, len))
+			return -EFAULT;
+		if (len < *lenp) {
+			if (copy_to_user(buffer + len, "\n", 1))
+				return -EFAULT;
+			len += 1;
+		}
+		*ppos += len;
+		*lenp -= len;
+	}
+	return len;
+}
+
 static int proc_cpt_table(struct ctl_table *table, int write,
 			  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -512,14 +610,14 @@ static int proc_cpt_distance(struct ctl_table *table, int write,
 		.data		= lnet_debug_log_upcall,
 		.maxlen		= sizeof(lnet_debug_log_upcall),
 		.mode		= 0644,
-		.proc_handler	= &proc_dostring,
+		.proc_handler	= &debugfs_dostring,
 	},
 	{
 		.procname	= "catastrophe",
 		.data		= &libcfs_catastrophe,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &debugfs_doint,
 	},
 	{
 		.procname	= "dump_kernel",
@@ -538,7 +636,7 @@ static int proc_cpt_distance(struct ctl_table *table, int write,
 		.data		= &libcfs_watchdog_ratelimit,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
+		.proc_handler	= &debugfs_doint,
 		.extra1		= &min_watchdog_ratelimit,
 		.extra2		= &max_watchdog_ratelimit,
 	},
@@ -561,14 +659,14 @@ static int proc_cpt_distance(struct ctl_table *table, int write,
 		.data		= &cfs_fail_val,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &debugfs_doint
 	},
 	{
 		.procname	= "fail_err",
 		.data		= &cfs_fail_err,
 		.maxlen		= sizeof(cfs_fail_err),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &debugfs_doint,
 	},
 	{
 	}
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 96cc506..623899e 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -880,7 +880,7 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
 		.data		= &lnet_lnd_timeout,
 		.maxlen		= sizeof(lnet_lnd_timeout),
 		.mode		= 0444,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &debugfs_doint,
 	},
 	{
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
