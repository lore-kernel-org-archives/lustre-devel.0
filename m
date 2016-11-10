From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:34 -0500
Subject: [lustre-devel] [PATCH 04/35] staging: lustre: lov: init LOV stripe
	type beforehand
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

When lu_object_alloc() reaches to LOV object init, we need initialize
its stripe type beforehand, so that if something wrong in the conf
buffer, the object chain need to be traversed to free what has been
allocated, with LOV object type be set as LLT_EMPTY, and when the LOV
part is reached, it won't panic without knowing what stripe type it
is.

This patch also improves debug messages in lsm_unpackmd_common(), and
does not return error if the LOV device is still processing config
log while trying to verify a layout buffer.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6744
Reviewed-on: http://review.whamcloud.com/15362
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_ea.c       |   12 ++++++++----
 drivers/staging/lustre/lustre/lov/lov_internal.h |    5 +++++
 drivers/staging/lustre/lustre/lov/lov_object.c   |    1 +
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 53db170..218f275 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -177,17 +177,21 @@ static int lsm_unpackmd_common(struct lov_obd *lov,
 		if (lov_oinfo_is_dummy(loi))
 			continue;
 
-		if (loi->loi_ost_idx >= lov->desc.ld_tgt_count) {
-			CERROR("OST index %d more than OST count %d\n",
+		if (loi->loi_ost_idx >= lov->desc.ld_tgt_count &&
+		    !lov2obd(lov)->obd_process_conf) {
+			CERROR("%s: OST index %d more than OST count %d\n",
+			       (char *)lov->desc.ld_uuid.uuid,
 			       loi->loi_ost_idx, lov->desc.ld_tgt_count);
 			lov_dump_lmm_v1(D_WARNING, lmm);
 			return -EINVAL;
 		}
 
 		if (!lov->lov_tgts[loi->loi_ost_idx]) {
-			CERROR("OST index %d missing\n", loi->loi_ost_idx);
+			CERROR("%s: OST index %d missing\n",
+			       (char *)lov->desc.ld_uuid.uuid,
+			       loi->loi_ost_idx);
 			lov_dump_lmm_v1(D_WARNING, lmm);
-			return -EINVAL;
+			continue;
 		}
 
 		tgt_bytes = lov_tgt_maxbytes(lov->lov_tgts[loi->loi_ost_idx]);
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 5b151bb..774499c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -301,4 +301,9 @@ static inline bool lov_oinfo_is_dummy(const struct lov_oinfo *loi)
 	return false;
 }
 
+static inline struct obd_device *lov2obd(const struct lov_obd *lov)
+{
+	return container_of0(lov, struct obd_device, u.lov);
+}
+
 #endif
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 317311c..76d4256 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -802,6 +802,7 @@ int lov_object_init(const struct lu_env *env, struct lu_object *obj,
 	init_waitqueue_head(&lov->lo_waitq);
 	cl_object_page_init(lu2cl(obj), sizeof(struct lov_page));
 
+	lov->lo_type = LLT_EMPTY;
 	if (cconf->u.coc_layout.lb_buf) {
 		lsm = lov_unpackmd(dev->ld_lov,
 				   cconf->u.coc_layout.lb_buf,
-- 
1.7.1
