From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:47 -0400
Subject: [lustre-devel] [PATCH 10/45] lustre: sec: check permissions for
 changelogs access
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

root permissions should be checked when reading or clearing changelogs
from clients. In particular, if root is squashed via a nodemap entry,
it should not be allowed to access changelogs.
To achieve this send mdt body along with RQF_LLOG_ORIGIN_HANDLE_CREATE
and RQF_MDT_SET_INFO requests. And on server side, retrieve user
credentials and make sure they have root permission.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13064
Lustre-commit: 4e8fcee92d751 ("LU-13064 sec: check permissions for changelogs access")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/36990
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_req_layout.h |  1 +
 fs/lustre/ptlrpc/layout.c             | 15 ++++++++++++++-
 fs/lustre/ptlrpc/llog_client.c        |  4 ++++
 fs/lustre/ptlrpc/pack_generic.c       |  7 ++++++-
 fs/lustre/ptlrpc/ptlrpc_internal.h    | 19 +++++++++++++++++++
 5 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index ea6baef..f56dc8b 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -123,6 +123,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 
 extern struct req_format RQF_OBD_PING;
 extern struct req_format RQF_OBD_SET_INFO;
+extern struct req_format RQF_MDT_SET_INFO;
 extern struct req_format RQF_SEC_CTX;
 /* MGS req_format */
 extern struct req_format RQF_MGS_TARGET_REG;
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 6f849f0..fd8676d 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -348,6 +348,13 @@
 	&RMF_SETINFO_VAL
 };
 
+static const struct req_msg_field *mdt_set_info_client[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_SETINFO_KEY,
+	&RMF_SETINFO_VAL,
+	&RMF_MDT_BODY
+};
+
 static const struct req_msg_field *ost_grant_shrink_client[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_SETINFO_KEY,
@@ -549,7 +556,8 @@
 static const struct req_msg_field *llog_origin_handle_create_client[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_LLOGD_BODY,
-	&RMF_NAME
+	&RMF_NAME,
+	&RMF_MDT_BODY,
 };
 
 static const struct req_msg_field *llogd_body_only[] = {
@@ -698,6 +706,7 @@
 static struct req_format *req_formats[] = {
 	&RQF_OBD_PING,
 	&RQF_OBD_SET_INFO,
+	&RQF_MDT_SET_INFO,
 	&RQF_SEC_CTX,
 	&RQF_MGS_TARGET_REG,
 	&RQF_MGS_CONFIG_READ,
@@ -1238,6 +1247,10 @@ struct req_format RQF_OBD_SET_INFO =
 	DEFINE_REQ_FMT0("OBD_SET_INFO", obd_set_info_client, empty);
 EXPORT_SYMBOL(RQF_OBD_SET_INFO);
 
+struct req_format RQF_MDT_SET_INFO =
+	DEFINE_REQ_FMT0("MDT_SET_INFO", mdt_set_info_client, empty);
+EXPORT_SYMBOL(RQF_MDT_SET_INFO);
+
 struct req_format RQF_SEC_CTX =
 	DEFINE_REQ_FMT0("SEC_CTX", empty, empty);
 EXPORT_SYMBOL(RQF_SEC_CTX);
diff --git a/fs/lustre/ptlrpc/llog_client.c b/fs/lustre/ptlrpc/llog_client.c
index ff1ca36..aeefa8f 100644
--- a/fs/lustre/ptlrpc/llog_client.c
+++ b/fs/lustre/ptlrpc/llog_client.c
@@ -44,6 +44,8 @@
 #include <lustre_net.h>
 #include <linux/list.h>
 
+#include "ptlrpc_internal.h"
+
 #define LLOG_CLIENT_ENTRY(ctxt, imp) do {				\
 	mutex_lock(&ctxt->loc_mutex);					\
 	if (ctxt->loc_imp) {						\
@@ -120,6 +122,8 @@ static int llog_client_open(const struct lu_env *env,
 						   strlen(name) + 1);
 		LASSERT(tmp);
 		strcpy(tmp, name);
+
+		do_pack_body(req);
 	}
 
 	rc = ptlrpc_queue_wait(req);
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index dfde8cc..ec853d1 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1506,7 +1506,9 @@ int do_set_info_async(struct obd_import *imp,
 	char *tmp;
 	int rc;
 
-	req = ptlrpc_request_alloc(imp, &RQF_OBD_SET_INFO);
+	req = ptlrpc_request_alloc(imp, KEY_IS(KEY_CHANGELOG_CLEAR) ?
+					&RQF_MDT_SET_INFO :
+					&RQF_OBD_SET_INFO);
 	if (!req)
 		return -ENOMEM;
 
@@ -1520,6 +1522,9 @@ int do_set_info_async(struct obd_import *imp,
 		return rc;
 	}
 
+	if (KEY_IS(KEY_CHANGELOG_CLEAR))
+		do_pack_body(req);
+
 	tmp = req_capsule_client_get(&req->rq_pill, &RMF_SETINFO_KEY);
 	memcpy(tmp, key, keylen);
 	tmp = req_capsule_client_get(&req->rq_pill, &RMF_SETINFO_VAL);
diff --git a/fs/lustre/ptlrpc/ptlrpc_internal.h b/fs/lustre/ptlrpc/ptlrpc_internal.h
index b340de7..83995cc 100644
--- a/fs/lustre/ptlrpc/ptlrpc_internal.h
+++ b/fs/lustre/ptlrpc/ptlrpc_internal.h
@@ -377,4 +377,23 @@ static inline bool ptlrpc_req_is_disconnect(struct ptlrpc_request *req)
 		return false;
 }
 
+static inline void do_pack_body(struct ptlrpc_request *req)
+{
+	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
+						    &RMF_MDT_BODY);
+
+	if (!b)
+		return;
+
+	b->mbo_valid = 0;
+	b->mbo_eadatasize = 0;
+	b->mbo_flags = 0;
+	b->mbo_suppgid = -1;
+	b->mbo_uid = from_kuid(&init_user_ns, current_uid());
+	b->mbo_gid = from_kgid(&init_user_ns, current_gid());
+	b->mbo_fsuid = from_kuid(&init_user_ns, current_fsuid());
+	b->mbo_fsgid = from_kgid(&init_user_ns, current_fsgid());
+	b->mbo_capability = current_cap().cap[0];
+}
+
 #endif /* PTLRPC_INTERNAL_H */
-- 
1.8.3.1
