Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5E2A5C433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:25 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ADEE73AD84D;
	Thu, 13 Jan 2022 17:38:19 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6DAF73AD84A
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:10 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D3DD6100F332;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D03A7A8103; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:52 -0500
Message-Id: <1642124283-10148-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/24] lnet: libcfs: Remove D_TTY
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

From: Patrick Farrell <pfarrell@whamcloud.com>

The D_TTY flag is almost entirely unused and certainly not
needed.  Remove it so we have a spare flag to use for
iotrace.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15137
Lustre-commit: f9fe2977d184fbc8e ("LU-15317 libcfs: Remove D_TTY")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45751
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                 |  2 +-
 include/uapi/linux/lnet/libcfs_debug.h |  1 -
 net/lnet/libcfs/tracefile.c            | 51 +---------------------------------
 3 files changed, 2 insertions(+), 52 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 30e99c0..05f2f1a 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4883,7 +4883,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 	 */
 	if (!(fd->fd_flags & LL_FILE_FLOCK_WARNING)) {
 		fd->fd_flags |= LL_FILE_FLOCK_WARNING;
-		CDEBUG_LIMIT(D_TTY | D_CONSOLE,
+		CDEBUG_LIMIT(D_CONSOLE,
 			     "flock disabled, mount with '-o [local]flock' to enable\r\n");
 	}
 	return -EINVAL;
diff --git a/include/uapi/linux/lnet/libcfs_debug.h b/include/uapi/linux/lnet/libcfs_debug.h
index 6b64f0e..4cb6594 100644
--- a/include/uapi/linux/lnet/libcfs_debug.h
+++ b/include/uapi/linux/lnet/libcfs_debug.h
@@ -106,7 +106,6 @@ struct ptldebug_header {
 #define D_TRACE		0x00000001 /* ENTRY/EXIT markers */
 #define D_INODE		0x00000002
 #define D_SUPER		0x00000004
-#define D_TTY		0x00000008 /* notification printed to TTY */
 #define D_MALLOC	0x00000010 /* print malloc, free information */
 #define D_CACHE		0x00000020 /* cache-related items */
 #define D_INFO		0x00000040 /* general information */
diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index b27732a..948eaaa 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -44,7 +44,6 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/poll.h>
-#include <linux/tty.h>
 #include <linux/uaccess.h>
 #include "tracefile.h"
 
@@ -352,41 +351,6 @@ static void cfs_set_ptldebug_header(struct ptldebug_header *header,
 	header->ph_extern_pid = 0;
 }
 
-/**
- * tty_write_msg - write a message to a certain tty, not just the console.
- * @tty: the destination tty_struct
- * @msg: the message to write
- *
- * tty_write_message is not exported, so write a same function for it
- *
- */
-static void tty_write_msg(struct tty_struct *tty, const char *msg)
-{
-	mutex_lock(&tty->atomic_write_lock);
-	tty_lock(tty);
-	if (tty->ops->write && tty->count > 0)
-		tty->ops->write(tty, msg, strlen(msg));
-	tty_unlock(tty);
-	mutex_unlock(&tty->atomic_write_lock);
-	wake_up_interruptible_poll(&tty->write_wait, POLLOUT);
-}
-
-static void cfs_tty_write_message(const char *prefix, int mask, const char *msg)
-{
-	struct tty_struct *tty;
-
-	tty = get_current_tty();
-	if (!tty)
-		return;
-
-	tty_write_msg(tty, prefix);
-	if ((mask & D_EMERG) || (mask & D_ERROR))
-		tty_write_msg(tty, "Error");
-	tty_write_msg(tty, ": ");
-	tty_write_msg(tty, msg);
-	tty_kref_put(tty);
-}
-
 static void cfs_vprint_to_console(struct ptldebug_header *hdr, int mask,
 				  struct va_format *vaf, const char *file,
 				  const char *fn)
@@ -421,10 +385,6 @@ static void cfs_vprint_to_console(struct ptldebug_header *hdr, int mask,
 		else if (mask & (D_CONSOLE | libcfs_printk))
 			pr_info("%s: %pV", prefix, vaf);
 	}
-
-	if (mask & D_TTY)
-		/* tty_write_msg doesn't handle formatting */
-		cfs_tty_write_message(prefix, mask, vaf->fmt);
 }
 
 static void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
@@ -534,14 +494,6 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 	if (*(string_buf + needed - 1) != '\n') {
 		pr_info("Lustre: format at %s:%d:%s doesn't end in newline\n",
 			file, msgdata->msg_line, msgdata->msg_fn);
-	} else if (mask & D_TTY) {
-		/* TTY needs '\r\n' to move carriage to leftmost position */
-		if (needed < 2 || *(string_buf + needed - 2) != '\r')
-			pr_info("Lustre: format at %s:%d:%s doesn't end in '\\r\\n'\n",
-				file, msgdata->msg_line, msgdata->msg_fn);
-		if (strnchr(string_buf, needed, '%'))
-			pr_info("Lustre: format at %s:%d:%s mustn't contain %%\n",
-				file, msgdata->msg_line, msgdata->msg_fn);
 	}
 
 	header.ph_len = known_size + needed;
@@ -627,8 +579,7 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 	}
 
 	if (cdls && cdls->cdls_count) {
-		/* Do not allow print this to TTY */
-		cfs_print_to_console(&header, mask & ~D_TTY, file,
+		cfs_print_to_console(&header, mask, file,
 				     msgdata->msg_fn,
 				     "Skipped %d previous similar message%s\n",
 				     cdls->cdls_count,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
