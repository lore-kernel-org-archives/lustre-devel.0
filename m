From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:20 -0500
Subject: [lustre-devel] [PATCH 392/622] lustre: lu_object: Add missed
 qos_rr_init
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-393-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

The new lmv space hash code uses the lu_qos_rr struct, but
forgot to init it fully.  Specifically, the spin lock isn't
inited, causing failures.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12538
Lustre-commit: 5e6a30cc2f34 ("LU-12538 lod: Add missed qos_rr_init")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35490
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h | 1 +
 fs/lustre/lmv/lmv_obd.c       | 3 ++-
 fs/lustre/obdclass/lu_qos.c   | 7 +++++++
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 6b1064a..d2e84a3 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1388,6 +1388,7 @@ struct lu_qos {
 				 lq_reset:1;     /* zero current penalties */
 };
 
+void lu_qos_rr_init(struct lu_qos_rr *lqr);
 int lqos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
 int lqos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
 u64 lu_prandom_u64_max(u64 ep_ro);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index ae799db..e9f9c36 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1295,13 +1295,14 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	INIT_LIST_HEAD(&lmv->lmv_qos.lq_svr_list);
 	init_rwsem(&lmv->lmv_qos.lq_rw_sem);
 	lmv->lmv_qos.lq_dirty = 1;
-	lmv->lmv_qos.lq_rr.lqr_dirty = 1;
 	lmv->lmv_qos.lq_reset = 1;
 	/* Default priority is toward free space balance */
 	lmv->lmv_qos.lq_prio_free = 232;
 	/* Default threshold for rr (roughly 17%) */
 	lmv->lmv_qos.lq_threshold_rr = 43;
 
+	lu_qos_rr_init(&lmv->lmv_qos.lq_rr);
+
 	/*
 	 * initialize rr_index to lower 32bit of netid, so that client
 	 * can distribute subdirs evenly from the beginning.
diff --git a/fs/lustre/obdclass/lu_qos.c b/fs/lustre/obdclass/lu_qos.c
index 9fdcbc2..d4803e8 100644
--- a/fs/lustre/obdclass/lu_qos.c
+++ b/fs/lustre/obdclass/lu_qos.c
@@ -42,6 +42,13 @@
 #include <lustre_fid.h>
 #include <lu_object.h>
 
+void lu_qos_rr_init(struct lu_qos_rr *lqr)
+{
+	spin_lock_init(&lqr->lqr_alloc);
+	lqr->lqr_dirty = 1;
+}
+EXPORT_SYMBOL(lu_qos_rr_init);
+
 /**
  * Add a new target to Quality of Service (QoS) target table.
  *
-- 
1.8.3.1
