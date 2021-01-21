Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.9 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48CEBC433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:58 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D054423A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D054423A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B533C21FF8C;
	Thu, 21 Jan 2021 09:18:06 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AA73921FAED
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:16 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9498D1008497;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 93D1A1B49C; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:17:02 -0500
Message-Id: <1611249422-556-40-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 39/39] lustre: cksum: add lprocfs checksum
 support in MDC/MDT
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

Add missed support for checksum parameters in MDC and MDT
Handle T10-PI parameters in MDT similar to OFD, move all
functionality to target code and unify its usage in both
targets

WC-bug-id: https://jira.whamcloud.com/browse/LU-14194
Lustre-commit: 18d61a910bcc76 ("LU-14194 cksum: add lprocfs checksum support in MDC/MDT")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40971
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/lproc_mdc.c | 126 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/lustre/osc/lproc_osc.c |  10 ++--
 2 files changed, 131 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index ce03999..3a2c37a2 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -34,6 +34,7 @@
 
 #include <linux/vfs.h>
 #include <obd_class.h>
+#include <obd_cksum.h>
 #include <lprocfs_status.h>
 #include <lustre_osc.h>
 #include <cl_object.h>
@@ -87,6 +88,127 @@ static ssize_t mdc_max_dirty_mb_seq_write(struct file *file,
 }
 LDEBUGFS_SEQ_FOPS(mdc_max_dirty_mb);
 
+DECLARE_CKSUM_NAME;
+
+static int mdc_checksum_type_seq_show(struct seq_file *m, void *v)
+{
+	struct obd_device *obd = m->private;
+	int i;
+
+	if (!obd)
+		return 0;
+
+	for (i = 0; i < ARRAY_SIZE(cksum_name); i++) {
+		if ((BIT(i) & obd->u.cli.cl_supp_cksum_types) == 0)
+			continue;
+		if (obd->u.cli.cl_cksum_type == BIT(i))
+			seq_printf(m, "[%s] ", cksum_name[i]);
+		else
+			seq_printf(m, "%s ", cksum_name[i]);
+	}
+	seq_puts(m, "\n");
+
+	return 0;
+}
+
+static ssize_t mdc_checksum_type_seq_write(struct file *file,
+					   const char __user *buffer,
+					   size_t count, loff_t *off)
+{
+	struct seq_file *m = file->private_data;
+	struct obd_device *obd = m->private;
+	char kernbuf[10];
+	int rc = -EINVAL;
+	int i;
+
+	if (!obd)
+		return 0;
+
+	if (count > sizeof(kernbuf) - 1)
+		return -EINVAL;
+	if (copy_from_user(kernbuf, buffer, count))
+		return -EFAULT;
+
+	if (count > 0 && kernbuf[count - 1] == '\n')
+		kernbuf[count - 1] = '\0';
+	else
+		kernbuf[count] = '\0';
+
+	for (i = 0; i < ARRAY_SIZE(cksum_name); i++) {
+		if (strcmp(kernbuf, cksum_name[i]) == 0) {
+			obd->u.cli.cl_preferred_cksum_type = BIT(i);
+			if (obd->u.cli.cl_supp_cksum_types & BIT(i)) {
+				obd->u.cli.cl_cksum_type = BIT(i);
+				rc = count;
+			} else {
+				rc = -ENOTSUPP;
+			}
+			break;
+		}
+	}
+
+	return rc;
+}
+LDEBUGFS_SEQ_FOPS(mdc_checksum_type);
+
+static ssize_t checksums_show(struct kobject *kobj,
+			      struct attribute *attr, char *buf)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+
+	return scnprintf(buf, PAGE_SIZE, "%d\n", !!obd->u.cli.cl_checksum);
+}
+
+static ssize_t checksums_store(struct kobject *kobj,
+			       struct attribute *attr,
+			       const char *buffer,
+			       size_t count)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	bool val;
+	int rc;
+
+	rc = kstrtobool(buffer, &val);
+	if (rc)
+		return rc;
+
+	obd->u.cli.cl_checksum = val;
+
+	return count;
+}
+LUSTRE_RW_ATTR(checksums);
+
+static ssize_t checksum_dump_show(struct kobject *kobj,
+				  struct attribute *attr, char *buf)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+
+	return scnprintf(buf, PAGE_SIZE, "%d\n", !!obd->u.cli.cl_checksum_dump);
+}
+
+static ssize_t checksum_dump_store(struct kobject *kobj,
+				   struct attribute *attr,
+				   const char *buffer,
+				   size_t count)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	bool val;
+	int rc;
+
+	rc = kstrtobool(buffer, &val);
+	if (rc)
+		return rc;
+
+	obd->u.cli.cl_checksum_dump = val;
+
+	return count;
+}
+LUSTRE_RW_ATTR(checksum_dump);
+
 static int mdc_cached_mb_seq_show(struct seq_file *m, void *v)
 {
 	struct obd_device *obd = m->private;
@@ -503,6 +625,8 @@ static ssize_t mdc_dom_min_repsize_seq_write(struct file *file,
 	  .fops	=	&mdc_max_dirty_mb_fops		},
 	{ .name	=	"mdc_cached_mb",
 	  .fops	=	&mdc_cached_mb_fops		},
+	{ .name =	"checksum_type",
+	  .fops	=	&mdc_checksum_type_fops		},
 	{ .name	=	"timeouts",
 	  .fops	=	&mdc_timeouts_fops		},
 	{ .name	=	"contention_seconds",
@@ -526,6 +650,8 @@ static ssize_t mdc_dom_min_repsize_seq_write(struct file *file,
 
 static struct attribute *mdc_attrs[] = {
 	&lustre_attr_active.attr,
+	&lustre_attr_checksums.attr,
+	&lustre_attr_checksum_dump.attr,
 	&lustre_attr_max_rpcs_in_flight.attr,
 	&lustre_attr_max_mod_rpcs_in_flight.attr,
 	&lustre_attr_max_pages_per_rpc.attr,
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 89b55c3..e64176e 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -358,7 +358,7 @@ static ssize_t checksums_show(struct kobject *kobj,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 
-	return sprintf(buf, "%d\n", obd->u.cli.cl_checksum ? 1 : 0);
+	return scnprintf(buf, PAGE_SIZE, "%d\n", !!obd->u.cli.cl_checksum);
 }
 
 static ssize_t checksums_store(struct kobject *kobj,
@@ -381,10 +381,11 @@ static ssize_t checksums_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(checksums);
 
+DECLARE_CKSUM_NAME;
+
 static int osc_checksum_type_seq_show(struct seq_file *m, void *v)
 {
 	struct obd_device *obd = m->private;
-	DECLARE_CKSUM_NAME;
 	int i;
 
 	if (!obd)
@@ -408,10 +409,9 @@ static ssize_t osc_checksum_type_seq_write(struct file *file,
 {
 	struct seq_file *m = file->private_data;
 	struct obd_device *obd = m->private;
-	DECLARE_CKSUM_NAME;
 	char kernbuf[10];
-	int i;
 	int rc = -EINVAL;
+	int i;
 
 	if (!obd)
 		return 0;
@@ -479,7 +479,7 @@ static ssize_t checksum_dump_show(struct kobject *kobj,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 
-	return sprintf(buf, "%d\n", obd->u.cli.cl_checksum_dump ? 1 : 0);
+	return scnprintf(buf, PAGE_SIZE, "%d\n", !!obd->u.cli.cl_checksum_dump);
 }
 
 static ssize_t checksum_dump_store(struct kobject *kobj,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
