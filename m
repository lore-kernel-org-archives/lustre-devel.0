Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81006C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3CAE361222
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CAE361222
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B67AB2F74AE;
	Wed, 14 Apr 2021 21:04:04 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3EF4732F56F
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B0741100F365;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AF38C91883; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:28 -0400
Message-Id: <1618459361-17909-37-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 36/49] lnet: libcfs: discard
 cfs_trace_console_buffers[]
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

cfs_trace_console_buffers[] is a collection of buffers into which
various messages are formatted - with vscnprintf or similar - and
which are then passed to cfs_print_to_console which adds more
formatted information.

The two levels of formatting can instead be achieved using the "%pV"
format which takes a format-and-args.  If we do this, we don't need
cfs_trace_console_buffers[] and more.

One minor drawback is that cfs_tty_write_message() requires a final
string to print, not a format plus arguments.  This is only minor
because there is precisely one message that is ever sent to
cfs_tty_write_message(), and it contains no formatting.  So we now
generate a warning if the string passed with D_TTY ever contains
formatting, and just print that string ignoring any formatting.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14428
Lustre-commit: 95aa713f78e7acf9 ("LU-14428 libcfs: discard cfs_trace_console_buffers[]")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41489
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/tracefile.c | 159 ++++++++++++++++++++++++--------------------
 1 file changed, 88 insertions(+), 71 deletions(-)

diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index 32bab98..e3a063f 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -44,10 +44,11 @@
 #include <linux/kthread.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
+#include <linux/poll.h>
+#include <linux/tty.h>
 #include <linux/uaccess.h>
 #include "tracefile.h"
 
-#define CFS_TRACE_CONSOLE_BUFFER_SIZE	1024
 
 enum cfs_trace_buf_type {
 	CFS_TCD_TYPE_PROC = 0,
@@ -58,7 +59,6 @@ enum cfs_trace_buf_type {
 
 union cfs_trace_data_union (*cfs_trace_data[CFS_TCD_TYPE_CNT])[NR_CPUS] __cacheline_aligned;
 
-char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_CNT];
 char cfs_tracefile[TRACEFILE_NAME_SIZE];
 long long cfs_tracefile_size = CFS_TRACEFILE_SIZE;
 static struct tracefiled_ctl trace_tctl;
@@ -173,14 +173,6 @@ enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
 	return CFS_TCD_TYPE_PROC;
 }
 
-static inline char *cfs_trace_get_console_buffer(void)
-{
-	unsigned int i = get_cpu();
-	unsigned int j = cfs_trace_buf_idx_get();
-
-	return cfs_trace_console_buffers[i][j];
-}
-
 static inline struct cfs_trace_cpu_data *
 cfs_trace_get_tcd(void)
 {
@@ -373,9 +365,44 @@ static void cfs_set_ptldebug_header(struct ptldebug_header *header,
 	header->ph_extern_pid = 0;
 }
 
-static void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
-				 const char *buf, int len, const char *file,
-				 const char *fn)
+/**
+ * tty_write_msg - write a message to a certain tty, not just the console.
+ * @tty: the destination tty_struct
+ * @msg: the message to write
+ *
+ * tty_write_message is not exported, so write a same function for it
+ *
+ */
+static void tty_write_msg(struct tty_struct *tty, const char *msg)
+{
+	mutex_lock(&tty->atomic_write_lock);
+	tty_lock(tty);
+	if (tty->ops->write && tty->count > 0)
+		tty->ops->write(tty, msg, strlen(msg));
+	tty_unlock(tty);
+	mutex_unlock(&tty->atomic_write_lock);
+	wake_up_interruptible_poll(&tty->write_wait, POLLOUT);
+}
+
+static void cfs_tty_write_message(const char *prefix, int mask, const char *msg)
+{
+	struct tty_struct *tty;
+
+	tty = get_current_tty();
+	if (!tty)
+		return;
+
+	tty_write_msg(tty, prefix);
+	if ((mask & D_EMERG) || (mask & D_ERROR))
+		tty_write_msg(tty, "Error");
+	tty_write_msg(tty, ": ");
+	tty_write_msg(tty, msg);
+	tty_kref_put(tty);
+}
+
+static void cfs_vprint_to_console(struct ptldebug_header *hdr, int mask,
+				  struct va_format *vaf, const char *file,
+				  const char *fn)
 {
 	char *prefix = "Lustre";
 
@@ -384,29 +411,46 @@ static void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 
 	if (mask & D_CONSOLE) {
 		if (mask & D_EMERG)
-			pr_emerg("%sError: %.*s", prefix, len, buf);
+			pr_emerg("%sError: %pV", prefix, vaf);
 		else if (mask & D_ERROR)
-			pr_err("%sError: %.*s", prefix, len, buf);
+			pr_err("%sError: %pV", prefix, vaf);
 		else if (mask & D_WARNING)
-			pr_warn("%s: %.*s", prefix, len, buf);
+			pr_warn("%s: %pV", prefix, vaf);
 		else if (mask & libcfs_printk)
-			pr_info("%s: %.*s", prefix, len, buf);
+			pr_info("%s: %pV", prefix, vaf);
 	} else {
 		if (mask & D_EMERG)
-			pr_emerg("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
+			pr_emerg("%sError: %d:%d:(%s:%d:%s()) %pV", prefix,
 				 hdr->ph_pid, hdr->ph_extern_pid, file,
-				 hdr->ph_line_num, fn, len, buf);
+				 hdr->ph_line_num, fn, vaf);
 		else if (mask & D_ERROR)
-			pr_err("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
+			pr_err("%sError: %d:%d:(%s:%d:%s()) %pV", prefix,
 			       hdr->ph_pid, hdr->ph_extern_pid, file,
-			       hdr->ph_line_num, fn, len, buf);
+			       hdr->ph_line_num, fn, vaf);
 		else if (mask & D_WARNING)
-			pr_warn("%s: %d:%d:(%s:%d:%s()) %.*s", prefix,
+			pr_warn("%s: %d:%d:(%s:%d:%s()) %pV", prefix,
 				hdr->ph_pid, hdr->ph_extern_pid, file,
-				hdr->ph_line_num, fn, len, buf);
+				hdr->ph_line_num, fn, vaf);
 		else if (mask & (D_CONSOLE | libcfs_printk))
-			pr_info("%s: %.*s", prefix, len, buf);
+			pr_info("%s: %pV", prefix, vaf);
 	}
+
+	if (mask & D_TTY)
+		/* tty_write_msg doesn't handle formatting */
+		cfs_tty_write_message(prefix, mask, vaf->fmt);
+}
+
+static void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
+				 const char *file, const char *fn,
+				 const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	va_start(args, fmt);
+	vaf.fmt = fmt;
+	vaf.va = &args;
+	cfs_vprint_to_console(hdr, mask, &vaf, file, fn);
 }
 
 int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
@@ -508,6 +552,9 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 		if (needed < 2 || *(string_buf + needed - 2) != '\r')
 			pr_info("Lustre: format at %s:%d:%s doesn't end in '\\r\\n'\n",
 				file, msgdata->msg_line, msgdata->msg_fn);
+		if (strnchr(string_buf, needed, '%'))
+			pr_info("Lustre: format at %s:%d:%s mustn't contain %%\n",
+				file, msgdata->msg_line, msgdata->msg_fn);
 	}
 
 	header.ph_len = known_size + needed;
@@ -578,35 +625,27 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 	}
 
 	if (tcd) {
-		cfs_print_to_console(&header, mask, string_buf, needed, file,
-				     msgdata->msg_fn);
+		cfs_print_to_console(&header, mask, file, msgdata->msg_fn,
+				     "%s", string_buf);
 		cfs_trace_put_tcd(tcd);
 	} else {
-		string_buf = cfs_trace_get_console_buffer();
+		struct va_format vaf;
 
 		va_start(ap, format);
-		needed = vscnprintf(string_buf, CFS_TRACE_CONSOLE_BUFFER_SIZE,
-				    format, ap);
+		vaf.fmt = format;
+		vaf.va = &ap;
+		cfs_vprint_to_console(&header, mask,
+				      &vaf, file, msgdata->msg_fn);
 		va_end(ap);
-
-		cfs_print_to_console(&header, mask,
-				     string_buf, needed, file, msgdata->msg_fn);
-
-		put_cpu();
 	}
 
 	if (cdls && cdls->cdls_count) {
-		string_buf = cfs_trace_get_console_buffer();
-
-		needed = scnprintf(string_buf, CFS_TRACE_CONSOLE_BUFFER_SIZE,
-				   "Skipped %d previous similar message%s\n",
-				   cdls->cdls_count,
-				   (cdls->cdls_count > 1) ? "s" : "");
-
-		cfs_print_to_console(&header, mask,
-				     string_buf, needed, file, msgdata->msg_fn);
-
-		put_cpu();
+		/* Do not allow print this to TTY */
+		cfs_print_to_console(&header, mask & ~D_TTY, file,
+				     msgdata->msg_fn,
+				     "Skipped %d previous similar message%s\n",
+				     cdls->cdls_count,
+				     (cdls->cdls_count > 1) ? "s" : "");
 		cdls->cdls_count = 0;
 	}
 
@@ -626,8 +665,8 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 
 	cfs_set_ptldebug_header(&hdr, msgdata, CDEBUG_STACK());
 
-	cfs_print_to_console(&hdr, D_EMERG, str, strlen(str),
-			     msgdata->msg_file, msgdata->msg_fn);
+	cfs_print_to_console(&hdr, D_EMERG, msgdata->msg_file, msgdata->msg_fn,
+			     "%s", str);
 
 	panic("Lustre debug assertion failure\n");
 
@@ -793,7 +832,8 @@ void cfs_trace_debug_print(void)
 			p += strlen(fn) + 1;
 			len = hdr->ph_len - (int)(p - (char *)hdr);
 
-			cfs_print_to_console(hdr, D_EMERG, p, len, file, fn);
+			cfs_print_to_console(hdr, D_EMERG, file, fn,
+					     "%.*s", len, p);
 
 			p += len;
 		}
@@ -1272,24 +1312,8 @@ int cfs_tracefile_init(int max_pages)
 		tcd->tcd_shutting_down = 0;
 	}
 
-	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < CFS_TCD_TYPE_CNT; j++) {
-			cfs_trace_console_buffers[i][j] =
-				kmalloc(CFS_TRACE_CONSOLE_BUFFER_SIZE,
-					GFP_KERNEL);
-
-			if (!cfs_trace_console_buffers[i][j])
-				goto out_buffers;
-		}
-
 	return 0;
 
-out_buffers:
-	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
-			kfree(cfs_trace_console_buffers[i][j]);
-			cfs_trace_console_buffers[i][j] = NULL;
-		}
 out_trace_data:
 	for (i = 0; cfs_trace_data[i]; i++) {
 		kfree(cfs_trace_data[i]);
@@ -1331,18 +1355,11 @@ static void cfs_trace_cleanup(void)
 {
 	struct page_collection pc;
 	int i;
-	int j;
 
 	INIT_LIST_HEAD(&pc.pc_pages);
 
 	trace_cleanup_on_all_cpus();
 
-	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < CFS_TCD_TYPE_CNT; j++) {
-			kfree(cfs_trace_console_buffers[i][j]);
-			cfs_trace_console_buffers[i][j] = NULL;
-		}
-
 	for (i = 0; i < CFS_TCD_TYPE_CNT && cfs_trace_data[i]; i++) {
 		kfree(cfs_trace_data[i]);
 		cfs_trace_data[i] = NULL;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
