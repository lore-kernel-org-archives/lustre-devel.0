From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 20 Aug 2016 17:34:27 -0400
Subject: [lustre-devel] [PATCH 10/13] staging/lustre: Fix unnecessary
	parentheses around variables
In-Reply-To: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
References: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471728870-518753-11-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Emoly Liu <emoly.liu@intel.com>

This patch fixes all checkpatch occurences of
"CHECK: Unnecessary parentheses around xxx"
in Lustre code.

Signed-off-by: Emoly Liu <emoly.liu@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre/lustre_user.h   |  2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c              |  4 ++--
 drivers/staging/lustre/lustre/lov/lov_pool.c             | 16 ++++++++--------
 drivers/staging/lustre/lustre/obdclass/genops.c          |  4 ++--
 drivers/staging/lustre/lustre/obdclass/llog.c            |  2 +-
 drivers/staging/lustre/lustre/obdclass/lustre_handles.c  |  2 +-
 drivers/staging/lustre/lustre/obdclass/obd_config.c      |  2 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c       |  2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c          |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c      |  6 +++---
 10 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 5fc0c5c..e077687 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -978,7 +978,7 @@ struct hsm_user_request {
 /** Return pointer to data field in a hsm user request */
 static inline void *hur_data(struct hsm_user_request *hur)
 {
-	return &(hur->hur_user_item[hur->hur_request.hr_itemcount]);
+	return &hur->hur_user_item[hur->hur_request.hr_itemcount];
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index bc71e4f..52651c4 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -940,7 +940,7 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 	}
 	case LCFG_PARAM: {
 		struct lprocfs_static_vars lvars = { NULL };
-		struct lov_desc *desc = &(obd->u.lov.desc);
+		struct lov_desc *desc = &obd->u.lov.desc;
 
 		if (!desc) {
 			rc = -EINVAL;
@@ -1460,7 +1460,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		}
 
 		desc = (struct lov_desc *)data->ioc_inlbuf1;
-		memcpy(desc, &(lov->desc), sizeof(*desc));
+		memcpy(desc, &lov->desc, sizeof(*desc));
 
 		uuidp = (struct obd_uuid *)data->ioc_inlbuf2;
 		genp = (__u32 *)data->ioc_inlbuf3;
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 639e086..f8c8a36 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -61,7 +61,7 @@ void lov_pool_putref(struct pool_desc *pool)
 		LASSERT(hlist_unhashed(&pool->pool_hash));
 		LASSERT(list_empty(&pool->pool_list));
 		LASSERT(!pool->pool_debugfs_entry);
-		lov_ost_pool_free(&(pool->pool_obds));
+		lov_ost_pool_free(&pool->pool_obds);
 		kfree(pool);
 	}
 }
@@ -260,7 +260,7 @@ static int pool_proc_show(struct seq_file *s, void *v)
 	tgt = pool_tgt(iter->pool, iter->idx);
 	up_read(&pool_tgt_rw_sem(iter->pool));
 	if (tgt)
-		seq_printf(s, "%s\n", obd_uuid2str(&(tgt->ltd_uuid)));
+		seq_printf(s, "%s\n", obd_uuid2str(&tgt->ltd_uuid));
 
 	return 0;
 }
@@ -400,7 +400,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	struct pool_desc *new_pool;
 	int rc;
 
-	lov = &(obd->u.lov);
+	lov = &obd->u.lov;
 
 	if (strlen(poolname) > LOV_MAXPOOLNAME)
 		return -ENAMETOOLONG;
@@ -471,7 +471,7 @@ int lov_pool_del(struct obd_device *obd, char *poolname)
 	struct lov_obd *lov;
 	struct pool_desc *pool;
 
-	lov = &(obd->u.lov);
+	lov = &obd->u.lov;
 
 	/* lookup and kill hash reference */
 	pool = cfs_hash_del_key(lov->lov_pools_hash_body, poolname);
@@ -503,7 +503,7 @@ int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname)
 	unsigned int lov_idx;
 	int rc;
 
-	lov = &(obd->u.lov);
+	lov = &obd->u.lov;
 
 	pool = cfs_hash_lookup(lov->lov_pools_hash_body, poolname);
 	if (!pool)
@@ -517,7 +517,7 @@ int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname)
 		if (!lov->lov_tgts[lov_idx])
 			continue;
 		if (obd_uuid_equals(&ost_uuid,
-				    &(lov->lov_tgts[lov_idx]->ltd_uuid)))
+				    &lov->lov_tgts[lov_idx]->ltd_uuid))
 			break;
 	}
 	/* test if ost found in lov */
@@ -547,7 +547,7 @@ int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname)
 	unsigned int lov_idx;
 	int rc = 0;
 
-	lov = &(obd->u.lov);
+	lov = &obd->u.lov;
 
 	pool = cfs_hash_lookup(lov->lov_pools_hash_body, poolname);
 	if (!pool)
@@ -562,7 +562,7 @@ int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname)
 			continue;
 
 		if (obd_uuid_equals(&ost_uuid,
-				    &(lov->lov_tgts[lov_idx]->ltd_uuid)))
+				    &lov->lov_tgts[lov_idx]->ltd_uuid))
 			break;
 	}
 
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 47c6420..d135104 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -166,10 +166,10 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	    !type->typ_name)
 		goto failed;
 
-	*(type->typ_dt_ops) = *dt_ops;
+	*type->typ_dt_ops = *dt_ops;
 	/* md_ops is optional */
 	if (md_ops)
-		*(type->typ_md_ops) = *md_ops;
+		*type->typ_md_ops = *md_ops;
 	strcpy(type->typ_name, name);
 	spin_lock_init(&type->obd_type_lock);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 1784ca0..8f06141 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -80,7 +80,7 @@ static void llog_free_handle(struct llog_handle *loghandle)
 		LASSERT(list_empty(&loghandle->u.phd.phd_entry));
 	else if (loghandle->lgh_hdr->llh_flags & LLOG_F_IS_CAT)
 		LASSERT(list_empty(&loghandle->u.chd.chd_head));
-	LASSERT(sizeof(*(loghandle->lgh_hdr)) == LLOG_CHUNK_SIZE);
+	LASSERT(sizeof(*loghandle->lgh_hdr) == LLOG_CHUNK_SIZE);
 	kfree(loghandle->lgh_hdr);
 out:
 	kfree(loghandle);
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index 082f530..89276e6 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -214,7 +214,7 @@ static int cleanup_all_handles(void)
 		struct portals_handle *h;
 
 		spin_lock(&handle_hash[i].lock);
-		list_for_each_entry_rcu(h, &(handle_hash[i].head), h_link) {
+		list_for_each_entry_rcu(h, &handle_hash[i].head, h_link) {
 			CERROR("force clean handle %#llx addr %p ops %p\n",
 			       h->h_cookie, h, h->h_ops);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 8daf16e..2858712 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1026,7 +1026,7 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 
 					oldfs = get_fs();
 					set_fs(KERNEL_DS);
-					rc = (var->fops->write)(&fakefile, sval,
+					rc = var->fops->write(&fakefile, sval,
 								vallen, NULL);
 					set_fs(oldfs);
 				}
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index cb85ad5..f56742a 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -394,7 +394,7 @@ int lustre_start_mgc(struct super_block *sb)
 	    lsi->lsi_lmd->lmd_flags & LMD_FLG_NOIR)
 		data->ocd_connect_flags &= ~OBD_CONNECT_IMP_RECOV;
 	data->ocd_version = LUSTRE_VERSION_CODE;
-	rc = obd_connect(NULL, &exp, obd, &(obd->obd_uuid), data, NULL);
+	rc = obd_connect(NULL, &exp, obd, &obd->obd_uuid, data, NULL);
 	if (rc) {
 		CERROR("connect failed %d\n", rc);
 		goto out;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 4161718..80ac270 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2634,7 +2634,7 @@ static int osc_getstripe(struct lov_stripe_md *lsm,
 			lmm_objects =
 			    &(((struct lov_user_md_v1 *)lumk)->lmm_objects[0]);
 		else
-			lmm_objects = &(lumk->lmm_objects[0]);
+			lmm_objects = &lumk->lmm_objects[0];
 		lmm_objects->l_ost_oi = lsm->lsm_oi;
 	} else {
 		lum_size = lov_mds_md_size(0, lum.lmm_magic);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index b514f18..fd0e980 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1941,9 +1941,9 @@ void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 	int i;
 
 	for (i = 0; i < stripe_count; i++) {
-		lustre_swab_ost_id(&(lod[i].l_ost_oi));
-		__swab32s(&(lod[i].l_ost_gen));
-		__swab32s(&(lod[i].l_ost_idx));
+		lustre_swab_ost_id(&lod[i].l_ost_oi);
+		__swab32s(&lod[i].l_ost_gen);
+		__swab32s(&lod[i].l_ost_idx);
 	}
 }
 EXPORT_SYMBOL(lustre_swab_lov_user_md_objects);
-- 
2.7.4
