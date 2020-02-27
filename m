From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:12 -0500
Subject: [lustre-devel] [PATCH 264/622] lustre: mdc: reset
 lmm->lmm_stripe_offset in mdc_save_lovea
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-265-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

In order to prepare for replay lmm->lmm_stripe_offset (which contains
layout generation) has to be set to -1 (LOV_OFFSET_DEFAULT) in order
to not confuse lod_verify_v1v3

Fix patch for ("LU-169 lov: add generation number to LOV EA") which
was apart of original Lustre merger to Linux kernel.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12040
Lustre-commit: c872afa36ff5 ("LU-12040 mdc: reset lmm->lmm_stripe_offset in mdc_save_lovea")
Signed-off-by: Vladimir Saveliev <c17830@cray.com>
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Cray-bug-id: LUS-7008
Reviewed-on: https://review.whamcloud.com/34371
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_lib.c                 | 3 ++-
 fs/lustre/mdc/mdc_locks.c               | 8 ++++++--
 include/uapi/linux/lustre/lustre_user.h | 1 +
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 980676a..f0e5a84 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -406,7 +406,8 @@ void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		lum->lmm_magic = cpu_to_le32(LOV_USER_MAGIC_V1);
 		lum->lmm_stripe_size = 0;
 		lum->lmm_stripe_count = 0;
-		lum->lmm_stripe_offset = (typeof(lum->lmm_stripe_offset))(-1);
+		lum->lmm_stripe_offset =
+		  (typeof(lum->lmm_stripe_offset))LOV_OFFSET_DEFAULT;
 	} else {
 		memcpy(lum, ea, ealen);
 	}
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 05447ea..019eb35 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -220,8 +220,8 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 			  void *data, u32 size)
 {
 	struct req_capsule *pill = &req->rq_pill;
+	struct lov_user_md *lmm;
 	int rc = 0;
-	void *lmm;
 
 	if (req_capsule_get_size(pill, field, RCL_CLIENT) < size) {
 		rc = sptlrpc_cli_enlarge_reqbuf(req, field, size);
@@ -237,8 +237,12 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 
 	req_capsule_set_size(pill, field, RCL_CLIENT, size);
 	lmm = req_capsule_client_get(pill, field);
-	if (lmm)
+	if (lmm) {
 		memcpy(lmm, data, size);
+		/* overwrite layout generation returned from the MDS */
+		lmm->lmm_stripe_offset =
+		  (typeof(lmm->lmm_stripe_offset))LOV_OFFSET_DEFAULT;
+	}
 
 	return rc;
 }
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 1d402f1..3901eb2 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -404,6 +404,7 @@ struct ll_ioc_lease_id {
 
 #define LOV_MAXPOOLNAME 15
 #define LOV_POOLNAMEF "%.15s"
+#define LOV_OFFSET_DEFAULT      ((__u16)-1)
 
 #define LOV_MIN_STRIPE_BITS	16	/* maximum PAGE_SIZE (ia64), power of 2 */
 #define LOV_MIN_STRIPE_SIZE	(1 << LOV_MIN_STRIPE_BITS)
-- 
1.8.3.1
