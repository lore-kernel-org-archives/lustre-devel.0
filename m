From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:40 -0500
Subject: [lustre-devel] [PATCH 12/60] staging: lustre: lmv: Error not
	handled for lmv_find_target
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ulka Vaze <ulka.vaze@yahoo.in>, Aditya Pandit <panditadityashreesh@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Ulka Vaze <ulka.vaze@yahoo.in>

This issue is found by smatch; has been reported as-
Unchecked usage of potential ERR_PTR result in lmv_hsm_req_count
and lmv_hsm_req_build. Added ERR_PTR in both functions and also
return value check added.

Signed-off-by: Ulka Vaze <ulka.vaze@yahoo.in>
Signed-off-by: Aditya Pandit <panditadityashreesh@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6523
Reviewed-on: http://review.whamcloud.com/14918
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 6a3b83f..915415c 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -736,16 +736,18 @@ static int lmv_hsm_req_count(struct lmv_obd *lmv,
 	/* count how many requests must be sent to the given target */
 	for (i = 0; i < hur->hur_request.hr_itemcount; i++) {
 		curr_tgt = lmv_find_target(lmv, &hur->hur_user_item[i].hui_fid);
+		if (IS_ERR(curr_tgt))
+			return PTR_ERR(curr_tgt);
 		if (obd_uuid_equals(&curr_tgt->ltd_uuid, &tgt_mds->ltd_uuid))
 			nr++;
 	}
 	return nr;
 }
 
-static void lmv_hsm_req_build(struct lmv_obd *lmv,
-			      struct hsm_user_request *hur_in,
-			      const struct lmv_tgt_desc *tgt_mds,
-			      struct hsm_user_request *hur_out)
+static int lmv_hsm_req_build(struct lmv_obd *lmv,
+			     struct hsm_user_request *hur_in,
+			     const struct lmv_tgt_desc *tgt_mds,
+			     struct hsm_user_request *hur_out)
 {
 	int			i, nr_out;
 	struct lmv_tgt_desc    *curr_tgt;
@@ -756,6 +758,8 @@ static void lmv_hsm_req_build(struct lmv_obd *lmv,
 	for (i = 0; i < hur_in->hur_request.hr_itemcount; i++) {
 		curr_tgt = lmv_find_target(lmv,
 					   &hur_in->hur_user_item[i].hui_fid);
+		if (IS_ERR(curr_tgt))
+			return PTR_ERR(curr_tgt);
 		if (obd_uuid_equals(&curr_tgt->ltd_uuid, &tgt_mds->ltd_uuid)) {
 			hur_out->hur_user_item[nr_out] =
 				hur_in->hur_user_item[i];
@@ -765,6 +769,8 @@ static void lmv_hsm_req_build(struct lmv_obd *lmv,
 	hur_out->hur_request.hr_itemcount = nr_out;
 	memcpy(hur_data(hur_out), hur_data(hur_in),
 	       hur_in->hur_request.hr_data_len);
+
+	return 0;
 }
 
 static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
@@ -1041,15 +1047,17 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		} else {
 			/* split fid list to their respective MDS */
 			for (i = 0; i < count; i++) {
-				unsigned int		nr, reqlen;
-				int			rc1;
 				struct hsm_user_request *req;
+				size_t reqlen;
+				int nr, rc1;
 
 				tgt = lmv->tgts[i];
 				if (!tgt || !tgt->ltd_exp)
 					continue;
 
 				nr = lmv_hsm_req_count(lmv, hur, tgt);
+				if (nr < 0)
+					return nr;
 				if (nr == 0) /* nothing for this MDS */
 					continue;
 
@@ -1061,10 +1069,13 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 				if (!req)
 					return -ENOMEM;
 
-				lmv_hsm_req_build(lmv, hur, tgt, req);
+				rc1 = lmv_hsm_req_build(lmv, hur, tgt, req);
+				if (rc1 < 0)
+					goto hsm_req_err;
 
 				rc1 = obd_iocontrol(cmd, tgt->ltd_exp, reqlen,
 						    req, uarg);
+hsm_req_err:
 				if (rc1 != 0 && rc == 0)
 					rc = rc1;
 				kvfree(req);
-- 
1.8.3.1
