Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C78DFC07E9B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:51 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8405F6113B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8405F6113B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 60C2534FA91;
	Mon, 19 Jul 2021 05:32:34 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8F25434F962
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:19 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A0E726BE;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 953C1BD1D0; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:32:02 -0400
Message-Id: <1626697933-6971-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/18] lnet: libcfs: Add checksum speed under
 /sys/fs
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Arshad Hussain <arshad.hussain@aeoncomputing.com>

This patch adds total of registered checksum and all
registered checksum names along with their speed under
/sys/kernel/debug/lustre/checksum_speed

TestCase sanity/77m added.

Sample output:
$ lctl get_param checksum_speed
checksum_speed=adler32: 1955
crc32: 2423
crc32c: 14035

WC-bug-id: https://jira.whamcloud.com/browse/LU-11698
Lustre-commit: d775f9ae37975c85 ("LU-11698 libcfs: Add checksum speed under /sys/fs")
Signed-off-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-on: https://review.whamcloud.com/43943
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obd_sysfs.c       | 61 ++++++++++++++++++++++++++++++++++++
 include/linux/libcfs/libcfs_crypto.h |  3 ++
 net/lnet/libcfs/linux-crypto.c       |  3 +-
 3 files changed, 66 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/obd_sysfs.c b/fs/lustre/obdclass/obd_sysfs.c
index 43bbbe9..93d2abc 100644
--- a/fs/lustre/obdclass/obd_sysfs.c
+++ b/fs/lustre/obdclass/obd_sysfs.c
@@ -59,6 +59,7 @@
 #include <linux/seq_file.h>
 #include <linux/kobject.h>
 
+#include <linux/libcfs/libcfs_crypto.h>
 #include <uapi/linux/lnet/lnetctl.h>
 #include <obd_support.h>
 #include <obd_class.h>
@@ -420,6 +421,63 @@ static int obd_device_list_open(struct inode *inode, struct file *file)
 	.release = seq_release,
 };
 
+/* checksum_speed */
+static void *checksum_speed_start(struct seq_file *p, loff_t *pos)
+{
+	return pos;
+}
+
+static void checksum_speed_stop(struct seq_file *p, void *v)
+{
+}
+
+static void *checksum_speed_next(struct seq_file *p, void *v, loff_t *pos)
+{
+	++(*pos);
+	if (*pos >= CFS_HASH_ALG_SPEED_MAX - 1)
+		return NULL;
+
+	return pos;
+}
+
+static int checksum_speed_show(struct seq_file *p, void *v)
+{
+	loff_t index = *(loff_t *)v;
+
+	if (!index || index > CFS_HASH_ALG_SPEED_MAX - 1)
+		return 0;
+
+	seq_printf(p, "%s: %d\n", cfs_crypto_hash_name(index),
+		   cfs_crypto_hash_speeds[index]);
+
+	return 0;
+}
+
+static const struct seq_operations checksum_speed_sops = {
+	.start		= checksum_speed_start,
+	.stop		= checksum_speed_stop,
+	.next		= checksum_speed_next,
+	.show		= checksum_speed_show,
+};
+
+static int checksum_speed_open(struct inode *inode, struct file *file)
+{
+	int rc = seq_open(file, &checksum_speed_sops);
+
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
+static const struct file_operations checksum_speed_fops = {
+	.owner		= THIS_MODULE,
+	.open		= checksum_speed_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 static int
 health_check_seq_show(struct seq_file *m, void *unused)
 {
@@ -507,6 +565,9 @@ int class_procfs_init(void)
 
 	debugfs_create_file("health_check", 0444, debugfs_lustre_root,
 			    NULL, &health_check_fops);
+
+	debugfs_create_file("checksum_speed", 0444, debugfs_lustre_root,
+			    NULL, &checksum_speed_fops);
 out:
 	return rc;
 }
diff --git a/include/linux/libcfs/libcfs_crypto.h b/include/linux/libcfs/libcfs_crypto.h
index ef099e9..fc60220 100644
--- a/include/linux/libcfs/libcfs_crypto.h
+++ b/include/linux/libcfs/libcfs_crypto.h
@@ -135,6 +135,9 @@ enum cfs_crypto_hash_alg {
 	return NULL;
 }
 
+/*  Array of hash algorithm speed in MByte per second */
+extern int cfs_crypto_hash_speeds[CFS_HASH_ALG_MAX];
+
 /**
  * Return hash name for hash algorithm identifier
  *
diff --git a/net/lnet/libcfs/linux-crypto.c b/net/lnet/libcfs/linux-crypto.c
index aeaa623..7b4338a 100644
--- a/net/lnet/libcfs/linux-crypto.c
+++ b/net/lnet/libcfs/linux-crypto.c
@@ -39,7 +39,8 @@
 /**
  *  Array of hash algorithm speed in MByte per second
  */
-static int cfs_crypto_hash_speeds[CFS_HASH_ALG_MAX];
+int cfs_crypto_hash_speeds[CFS_HASH_ALG_MAX];
+EXPORT_SYMBOL(cfs_crypto_hash_speeds);
 
 /**
  * Initialize the state descriptor for the specified hash algorithm.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
