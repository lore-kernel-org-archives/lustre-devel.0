From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:25 -0400
Subject: [lustre-devel] [PATCH 006/151] lustre: support for gcc8
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

Building with gcc8 reports new warnings which are addressed in
this patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11233
Lustre-commit: 6601661f9632 ("LU-11233 build: support for gcc8")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34660
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c             | 14 ++++++++------
 fs/lustre/obdclass/genops.c         |  2 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  3 +--
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 1c43022..acef43d 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -640,6 +640,7 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 	if (remote_gf) {
 		struct getinfo_fid2path *ori_gf;
 		char *ptr;
+		int len;
 
 		ori_gf = karg;
 		if (strlen(ori_gf->gf_path) + 1 +
@@ -650,12 +651,13 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 
 		ptr = ori_gf->gf_path;
 
-		memmove(ptr + strlen(gf->gf_path) + 1, ptr,
-			strlen(ori_gf->gf_path));
-
-		strncpy(ptr, gf->gf_path, strlen(gf->gf_path));
-		ptr += strlen(gf->gf_path);
-		*ptr = '/';
+		len = strlen(gf->gf_path);
+		/* move the current path to the right to release space
+		 * for closer-to-root part
+		 */
+		memmove(ptr + len + 1, ptr, strlen(ori_gf->gf_path));
+		memcpy(ptr, gf->gf_path, len);
+		ptr[len] = '/';
 	}
 
 	CDEBUG(D_INFO, "%s: get path %s " DFID " rec: %llu ln: %u\n",
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 9a9de35..4b528a7 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -322,7 +322,7 @@ struct obd_device *class_newdev(const char *type_name, const char *name,
 
 	newdev->obd_conn_inprogress = 0;
 
-	strncpy(newdev->obd_uuid.uuid, uuid, strlen(uuid));
+	strncpy(newdev->obd_uuid.uuid, uuid, UUID_MAX);
 
 	CDEBUG(D_IOCTL, "Allocate new device %s (%p)\n",
 	       newdev->obd_name, newdev);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index b9585f6..871d4fb 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1763,7 +1763,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	struct kib_tx *tx;
 	int nob;
 	int post_credit = IBLND_POSTRX_PEER_CREDIT;
-	u64 ibprm_cookie;
+	u64 ibprm_cookie = rxmsg->ibm_u.putreq.ibprm_cookie;
 	int rc = 0;
 
 	LASSERT(iov_iter_count(to) <= rlen);
@@ -1796,7 +1796,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		break;
 
 	case IBLND_MSG_PUT_REQ: {
-		u64 ibprm_cookie = rxmsg->ibm_u.putreq.ibprm_cookie;
 		struct kib_msg *txmsg;
 		struct kib_rdma_desc *rd;
 
-- 
1.8.3.1
