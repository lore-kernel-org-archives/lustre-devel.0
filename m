From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:11 -0500
Subject: [lustre-devel] [PATCH 143/622] lustre: mdc: grow lvb buffer to hold
 layout
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-144-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

Write intent RPC could generate a layout bigger than the initial
mdt_max_mdsize, so that the new layout cannot be returned to client,
this patch fix the client side issue by:

* define a new MAX_MD_SIZE to hold a reasonal composite layout, and
  keeps old MAX_MD_SIZE as MAX_MD_SIZE_OLD.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11158
Lustre-commit: e5abcf83c057 ("LU-11158 mdt: grow lvb buffer to hold layout")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32847
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_locks.c              | 4 +++-
 include/uapi/linux/lustre/lustre_idl.h | 5 ++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 09f9bc5..f9d66a4 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -614,7 +614,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	    (!it_disposition(it, DISP_OPEN_OPEN) || it->it_status != 0))
 		mdc_clear_replay_flag(req, it->it_status);
 
-	DEBUG_REQ(D_RPCTRACE, req, "op: %d disposition: %x, status: %d",
+	DEBUG_REQ(D_RPCTRACE, req, "op: %x disposition: %x, status: %d",
 		  it->it_op, it->it_disposition, it->it_status);
 
 	/* We know what to expect, so we do any byte flipping required here */
@@ -680,6 +680,8 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		 * is packed into RMF_DLM_LVB of req
 		 */
 		lvb_len = req_capsule_get_size(pill, &RMF_DLM_LVB, RCL_SERVER);
+		CDEBUG(D_INFO, "%s: layout return lvb %d transno %lld\n",
+		       class_exp2obd(exp)->obd_name, lvb_len, req->rq_transno);
 		if (lvb_len > 0) {
 			lvb_data = req_capsule_server_sized_get(pill,
 								&RMF_DLM_LVB,
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 8002e046..2f15671 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1049,8 +1049,11 @@ struct lov_mds_md_v1 {		/* LOV EA mds/wire data (little-endian) */
 	struct lov_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 };
 
-#define MAX_MD_SIZE							\
+#define MAX_MD_SIZE_OLD							\
 	(sizeof(struct lov_mds_md) + 4 * sizeof(struct lov_ost_data))
+#define MAX_MD_SIZE							\
+	(sizeof(struct lov_comp_md_v1) +				\
+	 4 * (sizeof(struct lov_comp_md_entry_v1) + MAX_MD_SIZE_OLD))
 #define MIN_MD_SIZE							\
 	(sizeof(struct lov_mds_md) + 1 * sizeof(struct lov_ost_data))
 
-- 
1.8.3.1
