From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:51 -0400
Subject: [lustre-devel] [PATCH 052/124] staging: lustre: lmv: add testing
	for bad name hash
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-53-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

Enable testing of the lfsck recovery feature in the
client code for the case when name hash for some
entry becomes corrupt.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5519
Reviewed-on: http://review.whamcloud.com/11846
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/obd_support.h    |    1 +
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   10 +++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index d4c41d0..3144cca 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -479,6 +479,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_LFSCK_NO_AUTO		0x160b
 #define OBD_FAIL_LFSCK_NO_DOUBLESCAN	0x160c
 #define OBD_FAIL_LFSCK_INVALID_PFID	0x1619
+#define OBD_FAIL_LFSCK_BAD_NAME_HASH	0x1628
 
 /* UPDATE */
 #define OBD_FAIL_UPDATE_OBJ_NET			0x1700
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index d9f8003..fde71c9 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1575,9 +1575,13 @@ lmv_locate_target_for_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 	const struct lmv_oinfo *oinfo;
 	struct lmv_tgt_desc *tgt;
 
-	oinfo = lsm_name_to_stripe_info(lsm, name, namelen);
-	if (IS_ERR(oinfo))
-		return ERR_CAST(oinfo);
+	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_BAD_NAME_HASH)) {
+		oinfo = &lsm->lsm_md_oinfo[cfs_fail_val];
+	} else {
+		oinfo = lsm_name_to_stripe_info(lsm, name, namelen);
+		if (IS_ERR(oinfo))
+			return ERR_CAST(oinfo);
+	}
 
 	*fid = oinfo->lmo_fid;
 	*mds = oinfo->lmo_mds;
-- 
1.7.1
