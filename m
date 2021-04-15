Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11C38C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:22 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C897861222
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C897861222
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 713E02F74EA;
	Wed, 14 Apr 2021 21:04:08 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8846432F68F
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B3AF5100F366;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B27639188E; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:29 -0400
Message-Id: <1618459361-17909-38-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 37/49] lnet: libcfs: discard
 cfs_trace_copyin_string()
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

Instead of cfs_trace_copyin_string(), use memdup_user_nul().
This combines the allocation with the copyin, and nul-terminates.

The resulting code is a lot simpler.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14428
Lustre-commit: 67af976c806994ce ("LU-14428 libcfs: discard cfs_trace_copyin_string()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41490
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs_debug.h |  2 --
 net/lnet/libcfs/module.c            | 19 +++++-------
 net/lnet/libcfs/tracefile.c         | 59 +++++++------------------------------
 net/lnet/libcfs/tracefile.h         |  2 --
 net/lnet/lnet/router_proc.c         | 22 +++++++-------
 5 files changed, 30 insertions(+), 74 deletions(-)

diff --git a/include/linux/libcfs/libcfs_debug.h b/include/linux/libcfs/libcfs_debug.h
index 99905f7..93eb752 100644
--- a/include/linux/libcfs/libcfs_debug.h
+++ b/include/linux/libcfs/libcfs_debug.h
@@ -209,8 +209,6 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 	__printf(2, 3);
 
 /* other external symbols that tracefile provides: */
-int cfs_trace_copyin_string(char *knl_buffer, int knl_buffer_nob,
-			    const char __user *usr_buffer, int usr_buffer_nob);
 int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 			     const char *knl_buffer, char *append);
 
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index f9cc6df..93e9b9e 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -295,7 +295,7 @@ static int proc_dobitmasks(struct ctl_table *table, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	const int tmpstrlen = 512;
-	char *tmpstr;
+	char *tmpstr = NULL;
 	int rc;
 	size_t nob = *lenp;
 	loff_t pos = *ppos;
@@ -303,11 +303,10 @@ static int proc_dobitmasks(struct ctl_table *table, int write,
 	int is_subsys = (mask == &libcfs_subsystem_debug) ? 1 : 0;
 	int is_printk = (mask == &libcfs_printk) ? 1 : 0;
 
-	tmpstr = kzalloc(tmpstrlen, GFP_KERNEL);
-	if (!tmpstr)
-		return -ENOMEM;
-
 	if (!write) {
+		tmpstr = kzalloc(tmpstrlen, GFP_KERNEL);
+		if (!tmpstr)
+			return -ENOMEM;
 		libcfs_debug_mask2str(tmpstr, tmpstrlen, *mask, is_subsys);
 		rc = strlen(tmpstr);
 
@@ -318,13 +317,11 @@ static int proc_dobitmasks(struct ctl_table *table, int write,
 						      tmpstr + pos, "\n");
 		}
 	} else {
-		rc = cfs_trace_copyin_string(tmpstr, tmpstrlen, buffer, nob);
-		if (rc < 0) {
-			kfree(tmpstr);
-			return rc;
-		}
+		tmpstr = memdup_user_nul(buffer, nob);
+		if (!tmpstr)
+			return -ENOMEM;
 
-		rc = libcfs_debug_str2mask(mask, tmpstr, is_subsys);
+		rc = libcfs_debug_str2mask(mask, strim(tmpstr), is_subsys);
 		/* Always print LBUG/LASSERT to console, so keep this mask */
 		if (is_printk)
 			*mask |= D_EMERG;
diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index e3a063f..731623b 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -920,34 +920,6 @@ void cfs_trace_flush_pages(void)
 	}
 }
 
-int cfs_trace_copyin_string(char *knl_buffer, int knl_buffer_nob,
-			    const char __user *usr_buffer, int usr_buffer_nob)
-{
-	int nob;
-
-	if (usr_buffer_nob > knl_buffer_nob)
-		return -EOVERFLOW;
-
-	if (copy_from_user((void *)knl_buffer,
-			   usr_buffer, usr_buffer_nob))
-		return -EFAULT;
-
-	nob = strnlen(knl_buffer, usr_buffer_nob);
-	while (--nob >= 0)		/* strip trailing whitespace */
-		if (!isspace(knl_buffer[nob]))
-			break;
-
-	if (nob < 0)			/* empty string */
-		return -EINVAL;
-
-	if (nob == knl_buffer_nob)	/* no space to terminate */
-		return -EOVERFLOW;
-
-	knl_buffer[nob + 1] = 0;	/* terminate */
-	return 0;
-}
-EXPORT_SYMBOL(cfs_trace_copyin_string);
-
 int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 			     const char *knl_buffer, char *append)
 {
@@ -977,26 +949,20 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 int cfs_trace_dump_debug_buffer_usrstr(void __user *usr_str, int usr_str_nob)
 {
 	char *str;
+	char *path;
 	int rc;
 
-	if (usr_str_nob >= 2 * PAGE_SIZE)
-		return -EINVAL;
-	str = kzalloc(usr_str_nob + 1, GFP_KERNEL);
+	str = memdup_user_nul(usr_str, usr_str_nob);
 	if (!str)
 		return -ENOMEM;
 
-	rc = cfs_trace_copyin_string(str, usr_str_nob + 1,
-				     usr_str, usr_str_nob);
-	if (rc)
-		goto out;
-
-	if (str[0] != '/') {
+	path = strim(str);
+	if (path[0] != '/')
 		rc = -EINVAL;
-		goto out;
-	}
-	rc = cfs_tracefile_dump_all_pages(str);
-out:
+	else
+		rc = cfs_tracefile_dump_all_pages(str);
 	kfree(str);
+
 	return rc;
 }
 
@@ -1045,18 +1011,13 @@ int cfs_trace_daemon_command_usrstr(void __user *usr_str, int usr_str_nob)
 	char *str;
 	int rc;
 
-	if (usr_str_nob >= 2 * PAGE_SIZE)
-		return -EINVAL;
-	str = kzalloc(usr_str_nob + 1, GFP_KERNEL);
+	str = memdup_user_nul(usr_str, usr_str_nob);
 	if (!str)
 		return -ENOMEM;
 
-	rc = cfs_trace_copyin_string(str, usr_str_nob + 1,
-				     usr_str, usr_str_nob);
-	if (!rc)
-		rc = cfs_trace_daemon_command(str);
-
+	rc = cfs_trace_daemon_command(str);
 	kfree(str);
+
 	return rc;
 }
 
diff --git a/net/lnet/libcfs/tracefile.h b/net/lnet/libcfs/tracefile.h
index 5b90c1b..311ec8c 100644
--- a/net/lnet/libcfs/tracefile.h
+++ b/net/lnet/libcfs/tracefile.h
@@ -59,8 +59,6 @@
 int cfs_tracefile_init(int max_pages);
 void cfs_tracefile_exit(void);
 
-int cfs_trace_copyin_string(char *knl_buffer, int knl_buffer_nob,
-			    const char __user *usr_buffer, int usr_buffer_nob);
 int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 			     const char *knl_str, char *append);
 int cfs_trace_dump_debug_buffer_usrstr(void __user *usr_str, int usr_str_nob);
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 623899e..25d172d 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -743,7 +743,7 @@ struct lnet_portal_rotors {
 	const char	*pr_desc;
 };
 
-static struct lnet_portal_rotors	portal_rotors[] = {
+static struct lnet_portal_rotors portal_rotors[] = {
 	{
 		.pr_value = LNET_PTL_ROTOR_OFF,
 		.pr_name  = "OFF",
@@ -783,11 +783,11 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
 	int rc;
 	int i;
 
-	buf = kmalloc(buf_len, GFP_KERNEL);
-	if (!buf)
-		return -ENOMEM;
-
 	if (!write) {
+		buf = kmalloc(buf_len, GFP_KERNEL);
+		if (!buf)
+			return -ENOMEM;
+
 		lnet_res_lock(0);
 
 		for (i = 0; portal_rotors[i].pr_value >= 0; i++) {
@@ -810,12 +810,14 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
 			rc = cfs_trace_copyout_string(buffer, nob,
 						      buf + pos, "\n");
 		}
-		goto out;
+		kfree(buf);
+
+		return rc;
 	}
 
-	rc = cfs_trace_copyin_string(buf, buf_len, buffer, nob);
-	if (rc < 0)
-		goto out;
+	buf = memdup_user_nul(buffer, nob);
+	if (!buf)
+		return -ENOMEM;
 
 	tmp = strim(buf);
 
@@ -830,8 +832,8 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
 		}
 	}
 	lnet_res_unlock(0);
-out:
 	kfree(buf);
+
 	return rc;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
