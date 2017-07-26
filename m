From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:37:58 -0400
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: lov: use u64 instead of
	loff_t in lov_object_fiemap()
In-Reply-To: <1501083479-23069-1-git-send-email-jsimmons@infradead.org>
References: <1501083479-23069-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501083479-23069-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

Change loff_t to u64 in lov_object_fiemap() since loff_t is a signed
value type.

Otherwise there could be an overflow in
drivers/staging/lustre/lustre/lov/lov_object.c:1241 lov_object_fiemap()
warn: signed overflow undefined. 'fm_start + fm_length < fm_start'

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8773
Reviewed-on: https://review.whamcloud.com/23461
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_object.c | 38 +++++++++++++-------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 4913229..b33ed2a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -1003,12 +1003,12 @@ int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
  * \retval last_stripe		return the last stripe of the mapping
  */
 static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm,
-				   loff_t fm_start, loff_t fm_end,
+				   u64 fm_start, u64 fm_end,
 				   int start_stripe, int *stripe_count)
 {
 	int last_stripe;
-	loff_t obd_start;
-	loff_t obd_end;
+	u64 obd_start;
+	u64 obd_end;
 	int i, j;
 
 	if (fm_end - fm_start > lsm->lsm_stripe_size * lsm->lsm_stripe_count) {
@@ -1076,14 +1076,14 @@ static void fiemap_prepare_and_copy_exts(struct fiemap *fiemap,
  * \param fm_end [in]		logical end of mapping
  * \param start_stripe [out]	starting stripe will be returned in this
  */
-static loff_t fiemap_calc_fm_end_offset(struct fiemap *fiemap,
-					struct lov_stripe_md *lsm,
-					loff_t fm_start, loff_t fm_end,
-					int *start_stripe)
+static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
+				     struct lov_stripe_md *lsm,
+				     u64 fm_start, u64 fm_end,
+				     int *start_stripe)
 {
-	loff_t local_end = fiemap->fm_extents[0].fe_logical;
-	loff_t lun_start, lun_end;
-	loff_t fm_end_offset;
+	u64 local_end = fiemap->fm_extents[0].fe_logical;
+	u64 lun_start, lun_end;
+	u64 fm_end_offset;
 	int stripe_no = -1;
 	int i;
 
@@ -1150,10 +1150,10 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	struct cl_object *subobj = NULL;
 	struct fiemap *fm_local = NULL;
 	struct lov_stripe_md *lsm;
-	loff_t fm_start;
-	loff_t fm_end;
-	loff_t fm_length;
-	loff_t fm_end_offset;
+	u64 fm_start;
+	u64 fm_end;
+	u64 fm_length;
+	u64 fm_end_offset;
 	int count_local;
 	int ost_index = 0;
 	int start_stripe;
@@ -1250,11 +1250,11 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	for (cur_stripe = start_stripe; stripe_count > 0;
 	     --stripe_count,
 	     cur_stripe = (cur_stripe + 1) % lsm->lsm_stripe_count) {
-		loff_t req_fm_len; /* Stores length of required mapping */
-		loff_t len_mapped_single_call;
-		loff_t lun_start;
-		loff_t lun_end;
-		loff_t obd_object_end;
+		u64 req_fm_len; /* Stores length of required mapping */
+		u64 len_mapped_single_call;
+		u64 lun_start;
+		u64 lun_end;
+		u64 obd_object_end;
 		unsigned int ext_count;
 
 		cur_stripe_wrap = cur_stripe;
-- 
1.8.3.1
