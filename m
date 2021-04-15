Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 625C2C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:41 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 24890610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24890610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CAB9632F75C;
	Wed, 14 Apr 2021 21:04:16 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DAC6E32F494
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:50 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6C3AD100F34F;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6AAEC91884; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:06 -0400
Message-Id: <1618459361-17909-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/49] lustre: use with_imp_locked() more
 broadly.
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

Several places in lustre take u.cli.cl_sem to protect access to
u.cli.cl_import, and so could use with_imp_locked() achieving cleaner
code.

Using with_imp_locked() in functions calling
ptlrpc_set_import_active() requires care as that function gets a
write-lock on ->cl_sem.  So they need to use with_imp_locked() only to
get a counted reference on the imp, and must drop the lock before
calling ptlrpc_set_import_active().

This patch makes those changes and also:

- introduces with_imp_locked_nested() for sptlrpc_conf_client_adapt(),
- re-indents obd_cleanup_client_import(), which is only tangentially
  related the the main purpose of this patch,
- removes code in ldlm_flock_completion_ast() which takes a copy
  of cl_import, and doesn't use it.
- adds with_imp_locked() to two functions named 'active_store' which
  weren't using it but should
- removes with_imp_locked() from ping_show() and instead includes it
  in ptlrpc_obd_ping() where 'imp' is actually used.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9855
Lustre-commit: 168ec247779f3ab7 ("LU-9855 lustre: use with_imp_locked() more broadly.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39595
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h | 11 ++++-
 fs/lustre/include/obd_class.h      |  5 +-
 fs/lustre/mdc/lproc_mdc.c          | 14 +++---
 fs/lustre/mdc/mdc_request.c        | 12 ++---
 fs/lustre/mgc/mgc_request.c        | 94 +++++++++++++++++++-------------------
 fs/lustre/osc/lproc_osc.c          | 10 +++-
 fs/lustre/osc/osc_request.c        | 12 ++---
 fs/lustre/ptlrpc/pinger.c          | 21 +++++----
 fs/lustre/ptlrpc/sec_config.c      |  8 +---
 9 files changed, 98 insertions(+), 89 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 33d78de..9051de7 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -488,14 +488,21 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 
 /* You must use these macros when you want to refer to
  * the import in a client obd_device for a lprocfs entry
+ * Note that it is not safe to 'goto', 'return' or 'break'
+ * out of the body of this statement.  It *IS* safe to
+ * 'goto' the a label inside the statement, or to 'continue'
+ * to get out of the statement.
  */
-#define with_imp_locked(__obd, __imp, __rc)				\
-	for (down_read(&(__obd)->u.cli.cl_sem),				\
+#define with_imp_locked_nested(__obd, __imp, __rc, __nested)		\
+	for (down_read_nested(&(__obd)->u.cli.cl_sem, __nested),	\
 	     __imp = (__obd)->u.cli.cl_import,				\
 	     __rc = __imp ? 0 : -ENODEV;				\
 	     __imp ? 1 : (up_read(&(__obd)->u.cli.cl_sem), 0);		\
 	     __imp = NULL)
 
+#define with_imp_locked(__obd, __imp, __rc)	\
+	with_imp_locked_nested(__obd, __imp, __rc, 0)
+
 /* write the name##_seq_show function, call LDEBUGFS_SEQ_FOPS_RO for read-only
  * debugfs entries; otherwise, you will define name##_seq_write function also
  * for a read-write debugfs entry, and then call LDEBUGFS_SEQ_SEQ instead.
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index b441215..6bcd89b 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -520,9 +520,8 @@ static inline int obd_cleanup(struct obd_device *obd)
 
 static inline void obd_cleanup_client_import(struct obd_device *obd)
 {
-	/*
-	 * If we set up but never connected, the
-	 * client import will not have been cleaned.
+	/* If we set up but never connected, the client import will not
+	 * have been cleaned.
 	 */
 	down_write(&obd->u.cli.cl_sem);
 	if (obd->u.cli.cl_import) {
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 3a2c37a2..af2b725 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -342,6 +342,7 @@ static ssize_t active_store(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
+	struct obd_import *imp, *imp0;
 	bool val;
 	int rc;
 
@@ -349,15 +350,16 @@ static ssize_t active_store(struct kobject *kobj, struct attribute *attr,
 	if (rc)
 		return rc;
 
+	with_imp_locked(obd, imp0, rc)
+		imp = class_import_get(imp0);
 	/* opposite senses */
-	if (obd->u.cli.cl_import->imp_deactive == val) {
+	if (imp->imp_deactive == val)
 		rc = ptlrpc_set_import_active(obd->u.cli.cl_import, val);
-		if (rc)
-			count = rc;
-	} else {
+	else
 		CDEBUG(D_CONFIG, "activate %u: ignoring repeat request\n", val);
-	}
-	return count;
+
+	class_import_put(imp);
+	return rc ?: count;
 }
 LUSTRE_RW_ATTR(active);
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index a146af8..ef27af6 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1589,19 +1589,17 @@ static int mdc_statfs(const struct lu_env *env,
 	struct req_format *fmt;
 	struct ptlrpc_request *req;
 	struct obd_statfs *msfs;
-	struct obd_import *imp = NULL;
+	struct obd_import *imp, *imp0;
 	int rc;
 
 	/*
 	 * Since the request might also come from lprocfs, so we need
 	 * sync this with client_disconnect_export Bug15684
 	 */
-	down_read(&obd->u.cli.cl_sem);
-	if (obd->u.cli.cl_import)
-		imp = class_import_get(obd->u.cli.cl_import);
-	up_read(&obd->u.cli.cl_sem);
-	if (!imp)
-		return -ENODEV;
+	with_imp_locked(obd, imp0, rc)
+		imp = class_import_get(imp0);
+	if (rc)
+		return rc;
 
 	fmt = &RQF_MDS_STATFS;
 	if ((exp_connect_flags2(exp) & OBD_CONNECT2_SUM_STATFS) &&
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 8133f27..f115479 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -1133,6 +1133,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		int entry_len = sizeof(*entry);
 		int is_ost;
 		struct obd_device *obd;
+		struct obd_import *imp;
 		char *obdname;
 		char *cname;
 		char *params;
@@ -1210,8 +1211,8 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		pos += sprintf(obdname + pos, "-%s%04x",
 				  is_ost ? "OST" : "MDT", entry->mne_index);
 
-		cname = is_ost ? "osc" : "mdc";
-		pos += sprintf(obdname + pos, "-%s-%s", cname, inst);
+		cname = is_ost ? "osc" : "mdc",
+			pos += sprintf(obdname + pos, "-%s-%s", cname, inst);
 		lustre_cfg_bufs_reset(&bufs, obdname);
 
 		/* find the obd by obdname */
@@ -1230,54 +1231,56 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		pos += sprintf(params, "%s.import=%s", cname, "connection=");
 		uuid = buf + pos;
 
-		down_read(&obd->u.cli.cl_sem);
-		if (!obd->u.cli.cl_import) {
-			/* client does not connect to the OST yet */
-			up_read(&obd->u.cli.cl_sem);
-			rc = 0;
-			continue;
-		}
-
-		/* iterate all nids to find one */
-		/* find uuid by nid */
-		/* create import entries if they don't exist */
-		rc = client_import_add_nids_to_conn(obd->u.cli.cl_import,
-						    entry->u.nids,
-						    entry->mne_nid_count,
-						    (struct obd_uuid *)uuid);
-		if (rc == -ENOENT && dynamic_nids) {
-			/* create a new connection for this import */
-			char *primary_nid = libcfs_nid2str(entry->u.nids[0]);
-			int prim_nid_len = strlen(primary_nid) + 1;
-			struct obd_uuid server_uuid;
-
-			if (prim_nid_len > UUID_MAX)
-				goto fail;
-			strncpy(server_uuid.uuid, primary_nid, prim_nid_len);
-
-			CDEBUG(D_INFO, "Adding a connection for %s\n",
-			       primary_nid);
-
-			rc = client_import_dyn_add_conn(obd->u.cli.cl_import,
-							&server_uuid,
-							entry->u.nids[0], 1);
-			if (rc < 0) {
-				CERROR("%s: Failed to add new connection with NID '%s' to import: rc = %d\n",
-				       obd->obd_name, primary_nid, rc);
-				goto fail;
-			}
-			rc = client_import_add_nids_to_conn(obd->u.cli.cl_import,
+		with_imp_locked(obd, imp, rc) {
+			/* iterate all nids to find one */
+			/* find uuid by nid */
+			/* create import entries if they don't exist */
+			rc = client_import_add_nids_to_conn(imp,
 							    entry->u.nids,
 							    entry->mne_nid_count,
 							    (struct obd_uuid *)uuid);
-			if (rc < 0) {
-				CERROR("%s: failed to lookup UUID: rc = %d\n",
-				       obd->obd_name, rc);
-				goto fail;
+			if (rc == -ENOENT && dynamic_nids) {
+				/* create a new connection for this import */
+				char *primary_nid =
+					libcfs_nid2str(entry->u.nids[0]);
+				int prim_nid_len = strlen(primary_nid) + 1;
+				struct obd_uuid server_uuid;
+
+				if (prim_nid_len > UUID_MAX)
+					goto fail;
+				strncpy(server_uuid.uuid, primary_nid,
+					prim_nid_len);
+
+				CDEBUG(D_INFO, "Adding a connection for %s\n",
+				       primary_nid);
+
+				rc = client_import_dyn_add_conn(imp,
+								&server_uuid,
+								entry->u.nids[0],
+								1);
+				if (rc < 0) {
+					CERROR("%s: Failed to add new connection with NID '%s' to import: rc = %d\n",
+					       obd->obd_name, primary_nid, rc);
+					goto fail;
+				}
+				rc = client_import_add_nids_to_conn(imp,
+								    entry->u.nids,
+								    entry->mne_nid_count,
+								    (struct obd_uuid *)uuid);
+				if (rc < 0) {
+					CERROR("%s: failed to lookup UUID: rc = %d\n",
+					       obd->obd_name, rc);
+					goto fail;
+				}
 			}
+fail:;
 		}
-fail:
-		up_read(&obd->u.cli.cl_sem);
+		if (rc == -ENODEV) {
+			/* client does not connect to the OST yet */
+			rc = 0;
+			continue;
+		}
+
 		if (rc < 0 && rc != -ENOSPC) {
 			CERROR("mgc: cannot find UUID by nid '%s': rc = %d\n",
 			       libcfs_nid2str(entry->u.nids[0]), rc);
@@ -1293,7 +1296,6 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 
 		lustre_cfg_bufs_set_string(&bufs, 1, params);
 
-		rc = -ENOMEM;
 		len = lustre_cfg_len(bufs.lcfg_bufcount, bufs.lcfg_buflen);
 		lcfg = kzalloc(len, GFP_NOFS);
 		if (!lcfg) {
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index e64176e..df48c76 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -61,6 +61,7 @@ static ssize_t active_store(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
+	struct obd_import *imp, *imp0;
 	bool val;
 	int rc;
 
@@ -68,14 +69,19 @@ static ssize_t active_store(struct kobject *kobj, struct attribute *attr,
 	if (rc)
 		return rc;
 
+	with_imp_locked(obd, imp0, rc)
+		imp = class_import_get(imp0);
+	if (rc)
+		return rc;
 	/* opposite senses */
-	if (obd->u.cli.cl_import->imp_deactive == val)
+	if (imp->imp_deactive == val)
 		rc = ptlrpc_set_import_active(obd->u.cli.cl_import, val);
 	else
 		CDEBUG(D_CONFIG, "activate %u: ignoring repeat request\n",
 		       val);
+	class_import_put(imp);
 
-	return count;
+	return rc ?: count;
 }
 LUSTRE_RW_ATTR(active);
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 066ecdb..8046e33 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -3069,18 +3069,16 @@ static int osc_statfs(const struct lu_env *env, struct obd_export *exp,
 	struct obd_device *obd = class_exp2obd(exp);
 	struct obd_statfs *msfs;
 	struct ptlrpc_request *req;
-	struct obd_import *imp = NULL;
+	struct obd_import *imp, *imp0;
 	int rc;
 
 	/* Since the request might also come from lprocfs, so we need
 	 * sync this with client_disconnect_export Bug15684
 	 */
-	down_read(&obd->u.cli.cl_sem);
-	if (obd->u.cli.cl_import)
-		imp = class_import_get(obd->u.cli.cl_import);
-	up_read(&obd->u.cli.cl_sem);
-	if (!imp)
-		return -ENODEV;
+	with_imp_locked(obd, imp0, rc)
+		imp = class_import_get(imp0);
+	if (rc)
+		return rc;
 
 	/* We could possibly pass max_age in the request (as an absolute
 	 * timestamp or a "seconds.usec ago") so the target can avoid doing
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index 178153c..99d077b 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -71,17 +71,18 @@ int ptlrpc_obd_ping(struct obd_device *obd)
 {
 	int rc;
 	struct ptlrpc_request *req;
+	struct obd_import *imp;
 
-	req = ptlrpc_prep_ping(obd->u.cli.cl_import);
-	if (!req)
-		return -ENOMEM;
-
-	req->rq_send_state = LUSTRE_IMP_FULL;
-
-	rc = ptlrpc_queue_wait(req);
-
-	ptlrpc_req_finished(req);
-
+	with_imp_locked(obd, imp, rc) {
+		req = ptlrpc_prep_ping(imp);
+		if (!req) {
+			rc = -ENOMEM;
+			continue;
+		}
+		req->rq_send_state = LUSTRE_IMP_FULL;
+		rc = ptlrpc_queue_wait(req);
+		ptlrpc_req_finished(req);
+	}
 	return rc;
 }
 EXPORT_SYMBOL(ptlrpc_obd_ping);
diff --git a/fs/lustre/ptlrpc/sec_config.c b/fs/lustre/ptlrpc/sec_config.c
index 0891f2f..d9e3520 100644
--- a/fs/lustre/ptlrpc/sec_config.c
+++ b/fs/lustre/ptlrpc/sec_config.c
@@ -836,24 +836,20 @@ void sptlrpc_conf_choose_flavor(enum lustre_sec_part from,
 void sptlrpc_conf_client_adapt(struct obd_device *obd)
 {
 	struct obd_import *imp;
+	int rc;
 
 	LASSERT(strcmp(obd->obd_type->typ_name, LUSTRE_MDC_NAME) == 0 ||
 		strcmp(obd->obd_type->typ_name, LUSTRE_OSC_NAME) == 0);
 	CDEBUG(D_SEC, "obd %s\n", obd->u.cli.cl_target_uuid.uuid);
 
 	/* serialize with connect/disconnect import */
-	down_read_nested(&obd->u.cli.cl_sem, OBD_CLI_SEM_MDCOSC);
-
-	imp = obd->u.cli.cl_import;
-	if (imp) {
+	with_imp_locked_nested(obd, imp, rc, OBD_CLI_SEM_MDCOSC) {
 		write_lock(&imp->imp_sec_lock);
 		if (imp->imp_sec)
 			imp->imp_sec_expire = ktime_get_real_seconds() +
 				SEC_ADAPT_DELAY;
 		write_unlock(&imp->imp_sec_lock);
 	}
-
-	up_read(&obd->u.cli.cl_sem);
 }
 EXPORT_SYMBOL(sptlrpc_conf_client_adapt);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
