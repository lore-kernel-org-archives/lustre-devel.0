From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:58 -0500
Subject: [lustre-devel] [PATCH 250/622] lustre: lov: remove KEY_CACHE_SET to
 simplify the code
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-251-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Yang Sheng <ys@whamcloud.com>

We must invoke obd_set_info_async with KEY_CACHE_SET after
obd_connect for OSC device. In fact, It can be combined
in obd_connect to simplify the code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12072
Lustre-commit: 6d21fbbf018b ("LU-12072 lov: remove KEY_CACHE_SET to simplify the code")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34419
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h     |  2 +-
 fs/lustre/ldlm/ldlm_lib.c   | 14 +++++++++++++
 fs/lustre/llite/llite_lib.c | 13 ++----------
 fs/lustre/lmv/lmv_obd.c     |  3 ++-
 fs/lustre/lov/lov_obd.c     | 49 ++++++++++++++-------------------------------
 fs/lustre/osc/osc_request.c | 17 ----------------
 6 files changed, 34 insertions(+), 64 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 758efc1..2195f85 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -446,6 +446,7 @@ struct lmv_obd {
 	struct lmv_tgt_desc	**tgts;
 	struct obd_connect_data	conn_data;
 	struct kobject		*lmv_tgts_kobj;
+	void			*lmv_cache;
 };
 
 struct niobuf_local {
@@ -672,7 +673,6 @@ struct obd_device {
 /*      KEY_SET_INFO in lustre_idl.h */
 #define KEY_SPTLRPC_CONF	"sptlrpc_conf"
 
-#define KEY_CACHE_SET		"cache_set"
 #define KEY_CACHE_LRU_SHRINK	"cache_lru_shrink"
 
 /* Flags for op_xvalid */
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 11955b1..4a982ab 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -40,6 +40,7 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
+#include <cl_object.h>
 #include <obd.h>
 #include <obd_class.h>
 #include <lustre_dlm.h>
@@ -579,6 +580,19 @@ int client_connect_import(const struct lu_env *env,
 out_sem:
 	up_write(&cli->cl_sem);
 
+	if (!rc && localdata) {
+		LASSERT(!cli->cl_cache); /* only once */
+		cli->cl_cache = (struct cl_client_cache *)localdata;
+		cl_cache_incref(cli->cl_cache);
+		cli->cl_lru_left = &cli->cl_cache->ccc_lru_left;
+
+		/* add this osc into entity list */
+		LASSERT(list_empty(&cli->cl_lru_osc));
+		spin_lock(&cli->cl_cache->ccc_lru_lock);
+		list_add(&cli->cl_lru_osc, &cli->cl_cache->ccc_lru);
+		spin_unlock(&cli->cl_cache->ccc_lru_lock);
+	}
+
 	return rc;
 }
 EXPORT_SYMBOL(client_connect_import);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 795a1f1..57486b4 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -266,7 +266,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	data->ocd_brw_size = MD_MAX_BRW_SIZE;
 
 	err = obd_connect(NULL, &sbi->ll_md_exp, sbi->ll_md_obd,
-			  &sbi->ll_sb_uuid, data, NULL);
+			  &sbi->ll_sb_uuid, data, sbi->ll_cache);
 	if (err == -EBUSY) {
 		LCONSOLE_ERROR_MSG(0x14f,
 				   "An MDT (md %s) is performing recovery, of which this client is not a part. Please wait for recovery to complete, abort, or time out.\n",
@@ -462,7 +462,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	data->ocd_brw_size = DT_MAX_BRW_SIZE;
 
 	err = obd_connect(NULL, &sbi->ll_dt_exp, sbi->ll_dt_obd,
-			  &sbi->ll_sb_uuid, data, NULL);
+			  &sbi->ll_sb_uuid, data, sbi->ll_cache);
 	if (err == -EBUSY) {
 		LCONSOLE_ERROR_MSG(0x150,
 				   "An OST (dt %s) is performing recovery, of which this client is not a part.  Please wait for recovery to complete, abort, or time out.\n",
@@ -583,15 +583,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	}
 	cl_sb_init(sb);
 
-	err = obd_set_info_async(NULL, sbi->ll_dt_exp, sizeof(KEY_CACHE_SET),
-				 KEY_CACHE_SET, sizeof(*sbi->ll_cache),
-				 sbi->ll_cache, NULL);
-	if (err) {
-		CERROR("%s: Set cache_set failed: rc = %d\n",
-		       sbi->ll_dt_exp->exp_obd->obd_name, err);
-		goto out_root;
-	}
-
 	sb->s_root = d_make_root(root);
 	if (!sb->s_root) {
 		CERROR("%s: can't make root dentry\n",
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 6ad100c..9f3d6de 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -207,6 +207,7 @@ static int lmv_connect(const struct lu_env *env,
 
 	lmv->connected = 0;
 	lmv->conn_data = *data;
+	lmv->lmv_cache = localdata;
 
 	lmv->lmv_tgts_kobj = kobject_create_and_add("target_obds",
 						    &obd->obd_kset.kobj);
@@ -299,7 +300,7 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 	}
 
 	rc = obd_connect(NULL, &mdc_exp, mdc_obd, &obd->obd_uuid,
-			 &lmv->conn_data, NULL);
+			 &lmv->conn_data, lmv->lmv_cache);
 	if (rc) {
 		CERROR("target %s connect error %d\n", tgt->ltd_uuid.uuid, rc);
 		return rc;
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index cc0ca1c..240cc6f9 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -120,7 +120,7 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 static int lov_notify(struct obd_device *obd, struct obd_device *watched,
 		      enum obd_notify_event ev);
 
-int lov_connect_obd(struct obd_device *obd, u32 index, int activate,
+int lov_connect_osc(struct obd_device *obd, u32 index, int activate,
 		    struct obd_connect_data *data)
 {
 	struct lov_obd *lov = &obd->u.lov;
@@ -169,13 +169,13 @@ int lov_connect_obd(struct obd_device *obd, u32 index, int activate,
 
 	if (imp->imp_invalid) {
 		CDEBUG(D_CONFIG,
-		       "not connecting OSC %s; administratively disabled\n",
+		       "%s: not connecting - administratively disabled\n",
 		       obd_uuid2str(tgt_uuid));
 		return 0;
 	}
 
 	rc = obd_connect(NULL, &lov->lov_tgts[index]->ltd_exp, tgt_obd,
-			 &lov_osc_uuid, data, NULL);
+			 &lov_osc_uuid, data, lov->lov_cache);
 	if (rc || !lov->lov_tgts[index]->ltd_exp) {
 		CERROR("Target %s connect error %d\n",
 		       obd_uuid2str(tgt_uuid), rc);
@@ -231,12 +231,17 @@ static int lov_connect(const struct lu_env *env,
 
 	lov_tgts_getref(obd);
 
+	if (localdata) {
+		lov->lov_cache = localdata;
+		cl_cache_incref(lov->lov_cache);
+	}
+
 	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
 		tgt = lov->lov_tgts[i];
 		if (!tgt || obd_uuid_empty(&tgt->ltd_uuid))
 			continue;
 		/* Flags will be lowest common denominator */
-		rc = lov_connect_obd(obd, i, tgt->ltd_activate, &lov->lov_ocd);
+		rc = lov_connect_osc(obd, i, tgt->ltd_activate, &lov->lov_ocd);
 		if (rc) {
 			CERROR("%s: lov connect tgt %d failed: %d\n",
 			       obd->obd_name, i, rc);
@@ -381,20 +386,12 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 			struct obd_uuid lov_osc_uuid = {"LOV_OSC_UUID"};
 
 			rc = obd_connect(NULL, &tgt->ltd_exp, tgt->ltd_obd,
-					 &lov_osc_uuid, &lov->lov_ocd, NULL);
+					 &lov_osc_uuid, &lov->lov_ocd,
+					 lov->lov_cache);
 			if (rc || !tgt->ltd_exp) {
 				index = rc;
 				goto out;
 			}
-			rc = obd_set_info_async(NULL, tgt->ltd_exp,
-						sizeof(KEY_CACHE_SET),
-						KEY_CACHE_SET,
-						sizeof(struct cl_client_cache),
-						lov->lov_cache, NULL);
-			if (rc < 0) {
-				index = rc;
-				goto out;
-			}
 		}
 
 		if (lov->lov_tgts[index]->ltd_activate == activate) {
@@ -574,17 +571,16 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	CDEBUG(D_CONFIG, "idx=%d ltd_gen=%d ld_tgt_count=%d\n",
 	       index, tgt->ltd_gen, lov->desc.ld_tgt_count);
 
-	if (lov->lov_connects == 0) {
+	if (lov->lov_connects == 0)
 		/* lov_connect hasn't been called yet. We'll do the
-		 * lov_connect_obd on this target when that fn first runs,
+		 * lov_connect_osc on this target when that fn first runs,
 		 * because we don't know the connect flags yet.
 		 */
 		return 0;
-	}
 
 	lov_tgts_getref(obd);
 
-	rc = lov_connect_obd(obd, index, active, &lov->lov_ocd);
+	rc = lov_connect_osc(obd, index, active, &lov->lov_ocd);
 	if (rc)
 		goto out;
 
@@ -594,15 +590,6 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		goto out;
 	}
 
-	if (lov->lov_cache) {
-		rc = obd_set_info_async(NULL, tgt->ltd_exp,
-					sizeof(KEY_CACHE_SET), KEY_CACHE_SET,
-					sizeof(struct cl_client_cache),
-					lov->lov_cache, NULL);
-		if (rc < 0)
-			goto out;
-	}
-
 	rc = lov_notify(obd, tgt->ltd_exp->exp_obd,
 			active ? OBD_NOTIFY_CONNECT : OBD_NOTIFY_INACTIVE);
 
@@ -1216,14 +1203,8 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 
 	lov_tgts_getref(obddev);
 
-	if (KEY_IS(KEY_CHECKSUM)) {
+	if (KEY_IS(KEY_CHECKSUM))
 		do_inactive = true;
-	} else if (KEY_IS(KEY_CACHE_SET)) {
-		LASSERT(!lov->lov_cache);
-		lov->lov_cache = val;
-		do_inactive = true;
-		cl_cache_incref(lov->lov_cache);
-	}
 
 	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
 		tgt = lov->lov_tgts[i];
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 7a99ef2..a988cbf 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2899,23 +2899,6 @@ int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		return 0;
 	}
 
-	if (KEY_IS(KEY_CACHE_SET)) {
-		struct client_obd *cli = &obd->u.cli;
-
-		LASSERT(!cli->cl_cache); /* only once */
-		cli->cl_cache = val;
-		cl_cache_incref(cli->cl_cache);
-		cli->cl_lru_left = &cli->cl_cache->ccc_lru_left;
-
-		/* add this osc into entity list */
-		LASSERT(list_empty(&cli->cl_lru_osc));
-		spin_lock(&cli->cl_cache->ccc_lru_lock);
-		list_add(&cli->cl_lru_osc, &cli->cl_cache->ccc_lru);
-		spin_unlock(&cli->cl_cache->ccc_lru_lock);
-
-		return 0;
-	}
-
 	if (KEY_IS(KEY_CACHE_LRU_SHRINK)) {
 		struct client_obd *cli = &obd->u.cli;
 		long nr = atomic_long_read(&cli->cl_lru_in_list) >> 1;
-- 
1.8.3.1
