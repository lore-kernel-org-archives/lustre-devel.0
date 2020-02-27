From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:02 -0500
Subject: [lustre-devel] [PATCH 134/622] lustre: mdc: use old statfs format
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-135-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

when the client talks to old server with no support
for aggregated statfs

WC-bug-id: https://jira.whamcloud.com/browse/LU-11375
Lustre-commit: e70a6fd8a640 ("LU-11375 mdc: use old statfs format")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33162
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_req_layout.h | 1 +
 fs/lustre/mdc/mdc_request.c           | 9 +++++++--
 fs/lustre/ptlrpc/layout.c             | 8 +++++++-
 3 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index ed4fc42..36656c6 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -133,6 +133,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_format RQF_MDS_CONNECT;
 extern struct req_format RQF_MDS_DISCONNECT;
 extern struct req_format RQF_MDS_STATFS;
+extern struct req_format RQF_MDS_STATFS_NEW;
 extern struct req_format RQF_MDS_GET_ROOT;
 extern struct req_format RQF_MDS_SYNC;
 extern struct req_format RQF_MDS_GETXATTR;
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 15f94ea..5cc1e1f 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1474,6 +1474,7 @@ static int mdc_statfs(const struct lu_env *env,
 		      time64_t max_age, u32 flags)
 {
 	struct obd_device *obd = class_exp2obd(exp);
+	struct req_format *fmt;
 	struct ptlrpc_request *req;
 	struct obd_statfs *msfs;
 	struct obd_import *imp = NULL;
@@ -1490,8 +1491,12 @@ static int mdc_statfs(const struct lu_env *env,
 	if (!imp)
 		return -ENODEV;
 
-	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_STATFS,
-					LUSTRE_MDS_VERSION, MDS_STATFS);
+	fmt = &RQF_MDS_STATFS;
+	if ((exp_connect_flags2(exp) & OBD_CONNECT2_SUM_STATFS) &&
+	    (flags & OBD_STATFS_SUM))
+		fmt = &RQF_MDS_STATFS_NEW;
+	req = ptlrpc_request_alloc_pack(imp, fmt, LUSTRE_MDS_VERSION,
+					MDS_STATFS);
 	if (!req) {
 		rc = -ENOMEM;
 		goto output;
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index efbff69..92d2fc2 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -683,6 +683,7 @@
 	&RQF_MDS_GET_INFO,
 	&RQF_MDS_GET_ROOT,
 	&RQF_MDS_STATFS,
+	&RQF_MDS_STATFS_NEW,
 	&RQF_MDS_GETATTR,
 	&RQF_MDS_GETATTR_NAME,
 	&RQF_MDS_GETXATTR,
@@ -1250,9 +1251,13 @@ struct req_format RQF_MDS_GET_ROOT =
 EXPORT_SYMBOL(RQF_MDS_GET_ROOT);
 
 struct req_format RQF_MDS_STATFS =
-	DEFINE_REQ_FMT0("MDS_STATFS", mdt_body_only, obd_statfs_server);
+	DEFINE_REQ_FMT0("MDS_STATFS", empty, obd_statfs_server);
 EXPORT_SYMBOL(RQF_MDS_STATFS);
 
+struct req_format RQF_MDS_STATFS_NEW =
+	DEFINE_REQ_FMT0("MDS_STATFS_NEW", mdt_body_only, obd_statfs_server);
+EXPORT_SYMBOL(RQF_MDS_STATFS_NEW);
+
 struct req_format RQF_MDS_SYNC =
 	DEFINE_REQ_FMT0("MDS_SYNC", mdt_body_capa, mdt_body_only);
 EXPORT_SYMBOL(RQF_MDS_SYNC);
@@ -2134,6 +2139,7 @@ u32 req_capsule_fmt_size(u32 magic, const struct req_format *fmt,
 			size += cfs_size_round(fmt->rf_fields[loc].d[i]->rmf_size);
 	return size;
 }
+EXPORT_SYMBOL(req_capsule_fmt_size);
 
 /**
  * Changes the format of an RPC.
-- 
1.8.3.1
