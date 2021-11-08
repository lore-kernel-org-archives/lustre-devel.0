Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C96BC433F5
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:07:55 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 092956113A
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:07:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 092956113A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EAC3021CAD5;
	Mon,  8 Nov 2021 07:07:52 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7E53121C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:48 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0D3BA2221;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 037D3E07E7; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:30 -0500
Message-Id: <1636384063-13838-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/15] lustre: mdc: add support for grant
 shrink
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

From: Alex Zhuravlev <bzzz@whamcloud.com>

just re-use existing mechanism used in OSC

WC-bug-id: https://jira.whamcloud.com/browse/LU-15010
Lustre-commit: 6e116213e3fd7d726 ("LU-15010 mdc: add support for grant shrink")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44956
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |   2 +
 fs/lustre/llite/llite_lib.c    |   1 +
 fs/lustre/mdc/lproc_mdc.c      | 106 +++++++++++++++++++++++++++++++++++++++++
 fs/lustre/osc/osc_request.c    |   2 +
 4 files changed, 111 insertions(+)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index cdc9aae..49a5e3b 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -680,6 +680,8 @@ int osc_punch_send(struct obd_export *exp, struct obdo *oa,
 		   obd_enqueue_update_f upcall, void *cookie);
 int osc_fallocate_base(struct obd_export *exp, struct obdo *oa,
 		       obd_enqueue_update_f upcall, void *cookie, int mode);
+void osc_update_next_shrink(struct client_obd *cli);
+void osc_schedule_grant_work(void);
 
 /* osc_io.c */
 int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index abd470a..51823b5 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -303,6 +303,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_SUBTREE	 |
 				  OBD_CONNECT_MULTIMODRPCS |
 				  OBD_CONNECT_GRANT_PARAM |
+				  OBD_CONNECT_GRANT_SHRINK |
 				  OBD_CONNECT_SHORTIO | OBD_CONNECT_FLAGS2;
 
 	data->ocd_connect_flags2 = OBD_CONNECT2_DIR_MIGRATE |
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index d13a6b7..87beb1b 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -606,6 +606,108 @@ static ssize_t mdc_dom_min_repsize_seq_write(struct file *file,
 	{ NULL }
 };
 
+static ssize_t cur_lost_grant_bytes_show(struct kobject *kobj,
+					 struct attribute *attr,
+					 char *buf)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct client_obd *cli = &obd->u.cli;
+
+	return scnprintf(buf, PAGE_SIZE, "%lu\n", cli->cl_lost_grant);
+}
+LUSTRE_RO_ATTR(cur_lost_grant_bytes);
+
+static ssize_t cur_dirty_grant_bytes_show(struct kobject *kobj,
+					  struct attribute *attr,
+					  char *buf)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct client_obd *cli = &obd->u.cli;
+
+	return scnprintf(buf, PAGE_SIZE, "%lu\n", cli->cl_dirty_grant);
+}
+LUSTRE_RO_ATTR(cur_dirty_grant_bytes);
+
+static ssize_t grant_shrink_show(struct kobject *kobj, struct attribute *attr,
+				 char *buf)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct obd_import *imp;
+	ssize_t len;
+
+	with_imp_locked(obd, imp, len)
+		len = scnprintf(buf, PAGE_SIZE, "%d\n",
+				!imp->imp_grant_shrink_disabled &&
+				OCD_HAS_FLAG(&imp->imp_connect_data,
+					     GRANT_SHRINK));
+
+	return len;
+}
+
+static ssize_t grant_shrink_store(struct kobject *kobj, struct attribute *attr,
+				  const char *buffer, size_t count)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct obd_import *imp;
+	bool val;
+	int rc;
+
+	if (!obd)
+		return 0;
+
+	rc = kstrtobool(buffer, &val);
+	if (rc)
+		return rc;
+
+	with_imp_locked(obd, imp, rc) {
+		spin_lock(&imp->imp_lock);
+		imp->imp_grant_shrink_disabled = !val;
+		spin_unlock(&imp->imp_lock);
+	}
+
+	return rc ?: count;
+}
+LUSTRE_RW_ATTR(grant_shrink);
+
+static ssize_t grant_shrink_interval_show(struct kobject *kobj,
+					  struct attribute *attr,
+					  char *buf)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+
+	return sprintf(buf, "%lld\n", obd->u.cli.cl_grant_shrink_interval);
+}
+
+static ssize_t grant_shrink_interval_store(struct kobject *kobj,
+					   struct attribute *attr,
+					   const char *buffer,
+					   size_t count)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	unsigned int val;
+	int rc;
+
+	rc = kstrtouint(buffer, 0, &val);
+	if (rc)
+		return rc;
+
+	if (val == 0)
+		return -ERANGE;
+
+	obd->u.cli.cl_grant_shrink_interval = val;
+	osc_update_next_shrink(&obd->u.cli);
+	osc_schedule_grant_work();
+
+	return count;
+}
+LUSTRE_RW_ATTR(grant_shrink_interval);
+
 static struct attribute *mdc_attrs[] = {
 	&lustre_attr_active.attr,
 	&lustre_attr_checksums.attr,
@@ -616,6 +718,10 @@ static ssize_t mdc_dom_min_repsize_seq_write(struct file *file,
 	&lustre_attr_mds_conn_uuid.attr,
 	&lustre_attr_conn_uuid.attr,
 	&lustre_attr_ping.attr,
+	&lustre_attr_grant_shrink.attr,
+	&lustre_attr_grant_shrink_interval.attr,
+	&lustre_attr_cur_lost_grant_bytes.attr,
+	&lustre_attr_cur_dirty_grant_bytes.attr,
 	NULL,
 };
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 22b7e5e..cf79808 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -770,6 +770,7 @@ void osc_update_next_shrink(struct client_obd *cli)
 	CDEBUG(D_CACHE, "next time %lld to shrink grant\n",
 	       cli->cl_next_shrink_grant);
 }
+EXPORT_SYMBOL(osc_update_next_shrink);
 
 static void __osc_update_grant(struct client_obd *cli, u64 grant)
 {
@@ -980,6 +981,7 @@ void osc_schedule_grant_work(void)
 	cancel_delayed_work_sync(&work);
 	schedule_work(&work.work);
 }
+EXPORT_SYMBOL(osc_schedule_grant_work);
 
 /**
  * Start grant thread for returing grant to server for idle clients.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
