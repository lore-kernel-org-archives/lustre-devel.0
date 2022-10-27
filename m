Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8DA5DFA3740
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:07:31 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MynXb5k5cz1yDf;
	Thu, 27 Oct 2022 07:06:23 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MynWy3Kd3z1wLC
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:05:50 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 74B6510090F7;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6A070FD4F2; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:30 -0400
Message-Id: <1666879542-10737-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/15] lustre: sec: retry ro mount if
 read-only flag set
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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

From: Sebastien Buisson <sbuisson@ddn.com>

In case client mount fails with -EROFS because the read-only nodemap
flag is set and ro mount option is not specified, just retry ro mount
internally. This is to avoid the need for users to manually retry the
mount with ro option.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15451
Lustre-commit: 56b5b5be43d88e604 ("LU-15451 sec: retry ro mount if read-only flag set")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/47490
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fld/fld_request.c       |  1 +
 fs/lustre/include/lu_object.h     |  1 +
 fs/lustre/ldlm/ldlm_lib.c         | 13 +++++++++++--
 fs/lustre/llite/llite_lib.c       | 21 ++++++++++++++++++---
 fs/lustre/lmv/lmv_obd.c           | 23 ++++++++++++++++-------
 fs/lustre/obdclass/lu_tgt_descs.c |  5 +++--
 6 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
index b365dc2..bafd5a9 100644
--- a/fs/lustre/fld/fld_request.c
+++ b/fs/lustre/fld/fld_request.c
@@ -224,6 +224,7 @@ static void fld_client_debugfs_init(struct lu_client_fld *fld)
 
 	ldebugfs_add_vars(fld->lcf_debugfs_entry, fld_client_debugfs_list, fld);
 }
+EXPORT_SYMBOL(fld_client_del_target);
 
 void fld_client_debugfs_fini(struct lu_client_fld *fld)
 {
diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 5c7f439..4e101fa 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1592,6 +1592,7 @@ struct lu_tgt_descs {
 
 u64 lu_prandom_u64_max(u64 ep_ro);
 int lu_qos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
+int lu_qos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
 void lu_tgt_qos_weight_calc(struct lu_tgt_desc *tgt);
 
 int lu_tgt_descs_init(struct lu_tgt_descs *ltd, bool is_mdt);
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 804bb9c..08aff4f 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -593,6 +593,16 @@ int client_connect_import(const struct lu_env *env,
 
 	LASSERT(obd->obd_namespace);
 
+	spin_lock(&imp->imp_lock);
+	if (imp->imp_state == LUSTRE_IMP_CLOSED && imp->imp_deactive) {
+		/* need to reactivate import if trying to connect
+		 * to a previously disconnected
+		 */
+		imp->imp_deactive = 0;
+		imp->imp_invalid = 0;
+	}
+	spin_unlock(&imp->imp_lock);
+
 	imp->imp_dlm_handle = conn;
 	rc = ptlrpc_init_import(imp);
 	if (rc != 0)
@@ -631,8 +641,7 @@ int client_connect_import(const struct lu_env *env,
 out_sem:
 	up_write(&cli->cl_sem);
 
-	if (!rc && localdata) {
-		LASSERT(!cli->cl_cache); /* only once */
+	if (!rc && localdata && !cli->cl_cache) {
 		cli->cl_cache = (struct cl_client_cache *)localdata;
 		cl_cache_incref(cli->cl_cache);
 		cli->cl_lru_left = &cli->cl_cache->ccc_lru_left;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 191a83c..55a9202 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -363,6 +363,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	data->ocd_brw_size = MD_MAX_BRW_SIZE;
 
+retry_connect:
+	if (sb_rdonly(sb))
+		data->ocd_connect_flags |= OBD_CONNECT_RDONLY;
 	err = obd_connect(NULL, &sbi->ll_md_exp, sbi->ll_md_obd,
 			  &sbi->ll_sb_uuid, data, sbi->ll_cache);
 	if (err == -EBUSY) {
@@ -405,8 +408,20 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	err = obd_statfs(NULL, sbi->ll_md_exp, osfs,
 			 ktime_get_seconds() - sbi->ll_statfs_max_age,
 			 OBD_STATFS_FOR_MDT0);
-	if (err)
+	if (err == -EROFS && !sb_rdonly(sb)) {
+		/* We got -EROFS from the server, maybe it is imposing
+		 * read-only mount. So just retry like this.
+		 */
+		LCONSOLE_INFO("Forcing read-only mount.\n\r");
+		CERROR("%s: mount failed with %d, forcing read-only mount.\n",
+		       sbi->ll_md_exp->exp_obd->obd_name, err);
+		sb->s_flags |= SB_RDONLY;
+		obd_fid_fini(sbi->ll_md_exp->exp_obd);
+		obd_disconnect(sbi->ll_md_exp);
+		goto retry_connect;
+	} else if (err) {
 		goto out_md_fid;
+	}
 
 	/* This needs to be after statfs to ensure connect has finished.
 	 * Note that "data" does NOT contain the valid connect reply.
@@ -1329,8 +1344,8 @@ int ll_fill_super(struct super_block *sb)
 	if (err)
 		ll_put_super(sb);
 	else if (test_bit(LL_SBI_VERBOSE, sbi->ll_flags))
-		LCONSOLE_WARN("Mounted %s\n", profilenm);
-
+		LCONSOLE_WARN("Mounted %s%s\n", profilenm,
+			      sb_rdonly(sb) ? " read-only" : "");
 	return err;
 } /* ll_fill_super */
 
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 84d583e..3a02cc1 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -494,24 +494,33 @@ static int lmv_disconnect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 					  mdc_obd->obd_name);
 	}
 
+	rc = lu_qos_del_tgt(&lmv->lmv_qos, tgt);
+	if (rc)
+		CERROR("%s: Can't del target from QoS table: rc = %d\n",
+		       tgt->ltd_exp->exp_obd->obd_name, rc);
+
+	rc = fld_client_del_target(&lmv->lmv_fld, tgt->ltd_index);
+	if (rc)
+		CERROR("%s: Can't del fld targets: rc = %d\n",
+		       tgt->ltd_exp->exp_obd->obd_name, rc);
+
 	rc = obd_fid_fini(tgt->ltd_exp->exp_obd);
 	if (rc)
-		CERROR("Can't finalize fids factory\n");
+		CERROR("%s: Can't finalize fids factory: rc = %d\n",
+		       tgt->ltd_exp->exp_obd->obd_name, rc);
 
 	CDEBUG(D_INFO, "Disconnected from %s(%s) successfully\n",
 	       tgt->ltd_exp->exp_obd->obd_name,
 	       tgt->ltd_exp->exp_obd->obd_uuid.uuid);
 
+	lmv_activate_target(lmv, tgt, 0);
 	obd_register_observer(tgt->ltd_exp->exp_obd, NULL);
 	rc = obd_disconnect(tgt->ltd_exp);
 	if (rc) {
-		if (tgt->ltd_active) {
-			CERROR("Target %s disconnect error %d\n",
-			       tgt->ltd_uuid.uuid, rc);
-		}
+		CERROR("%s: Target %s disconnect error: rc = %d\n",
+		       tgt->ltd_exp->exp_obd->obd_name,
+		       tgt->ltd_uuid.uuid, rc);
 	}
-
-	lmv_activate_target(lmv, tgt, 0);
 	tgt->ltd_exp = NULL;
 	return 0;
 }
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index 51d2e21..7394789 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -170,7 +170,7 @@ int lu_qos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *tgt)
  * Return:	0 on success
  *		-ENOENT if no server was found
  */
-static int lu_qos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
+int lu_qos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
 {
 	struct lu_svr_qos *svr;
 	int rc = 0;
@@ -182,12 +182,12 @@ static int lu_qos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
 		goto out;
 	}
 
+	ltd->ltd_qos.ltq_svr = NULL;
 	svr->lsq_tgt_count--;
 	if (svr->lsq_tgt_count == 0) {
 		CDEBUG(D_OTHER, "removing server %s\n",
 		       obd_uuid2str(&svr->lsq_uuid));
 		list_del(&svr->lsq_svr_list);
-		ltd->ltd_qos.ltq_svr = NULL;
 		kfree(svr);
 	}
 
@@ -196,6 +196,7 @@ static int lu_qos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
 	up_write(&qos->lq_rw_sem);
 	return rc;
 }
+EXPORT_SYMBOL(lu_qos_del_tgt);
 
 static inline u64 tgt_statfs_bavail(struct lu_tgt_desc *tgt)
 {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
