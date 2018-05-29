From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:43 -0400
Subject: [lustre-devel] [PATCH v2 4/6] staging: lustre: acl: increase ACL
 entries limitation
In-Reply-To: <1527603705-30450-1-git-send-email-jsimmons@infradead.org>
References: <1527603705-30450-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603705-30450-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

Originally, the limitation of ACL entries is 32, that is not
enough for some use cases. In fact, restricting ACL entries
count is mainly for preparing the RPC reply buffer to receive
the ACL data. So we cannot make the ACL entries count to be
unlimited. But we can enlarge the RPC reply buffer to hold
more ACL entries. On the other hand, MDT backend filesystem
has its own EA size limitation. For example, for ldiskfs case,
if large EA enable, then the max ACL size is 1048492 bytes;
otherwise, it is 4012 bytes. For ZFS backend, such value is
32768 bytes. With such hard limitation, we can calculate how
many ACL entries we can have at most. This patch increases
the RPC reply buffer to match such hard limitation. For old
client, to avoid buffer overflow because of large ACL data
(more than 32 ACL entries), the MDT will forbid the old client
to access the file with large ACL data. As for how to know
whether it is old client or new, a new connection flag
OBD_CONNECT_LARGE_ACL is used for that.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7473
Reviewed-on: https://review.whamcloud.com/19790
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---

Changelog:

v1) Initial patch
v2) Rebased patch. No changes

 drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h | 2 +-
 drivers/staging/lustre/lustre/include/lustre_acl.h            | 7 ++++++-
 drivers/staging/lustre/lustre/llite/llite_lib.c               | 3 ++-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c                 | 6 ++++++
 drivers/staging/lustre/lustre/mdc/mdc_reint.c                 | 2 ++
 drivers/staging/lustre/lustre/mdc/mdc_request.c               | 4 ++++
 drivers/staging/lustre/lustre/ptlrpc/layout.c                 | 4 +---
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c               | 4 ++--
 8 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index aac98db..8778c6f 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -615,7 +615,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT_REQPORTAL		 0x40ULL /*Separate non-IO req portal */
 #define OBD_CONNECT_ACL			 0x80ULL /*access control lists */
 #define OBD_CONNECT_XATTR		0x100ULL /*client use extended attr */
-#define OBD_CONNECT_CROW		0x200ULL /*MDS+OST create obj on write*/
+#define OBD_CONNECT_LARGE_ACL		0x200ULL /* more than 32 ACL entries */
 #define OBD_CONNECT_TRUNCLOCK		0x400ULL /*locks on server for punch */
 #define OBD_CONNECT_TRANSNO		0x800ULL /*replay sends init transno */
 #define OBD_CONNECT_IBITS	       0x1000ULL /*support for inodebits locks*/
diff --git a/drivers/staging/lustre/lustre/include/lustre_acl.h b/drivers/staging/lustre/lustre/include/lustre_acl.h
index 35ff61c..e7575a1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_acl.h
+++ b/drivers/staging/lustre/lustre/include/lustre_acl.h
@@ -36,11 +36,16 @@
 
 #include <linux/fs.h>
 #include <linux/dcache.h>
+#ifdef CONFIG_FS_POSIX_ACL
 #include <linux/posix_acl_xattr.h>
 
 #define LUSTRE_POSIX_ACL_MAX_ENTRIES	32
-#define LUSTRE_POSIX_ACL_MAX_SIZE						\
+#define LUSTRE_POSIX_ACL_MAX_SIZE_OLD						\
 	(sizeof(struct posix_acl_xattr_header) +				\
 	 LUSTRE_POSIX_ACL_MAX_ENTRIES * sizeof(struct posix_acl_xattr_entry))
 
+#else /* ! CONFIG_FS_POSIX_ACL */
+#define LUSTRE_POSIX_ACL_MAX_SIZE_OLD 0
+#endif /* CONFIG_FS_POSIX_ACL */
+
 #endif
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 1bc0782..36066c8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -199,7 +199,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
 #ifdef CONFIG_FS_POSIX_ACL
-	data->ocd_connect_flags |= OBD_CONNECT_ACL | OBD_CONNECT_UMASK;
+	data->ocd_connect_flags |= OBD_CONNECT_ACL | OBD_CONNECT_UMASK |
+				   OBD_CONNECT_LARGE_ACL;
 #endif
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_LIGHTWEIGHT))
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 253a545..65a5341 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -308,6 +308,8 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     obddev->u.cli.cl_max_mds_easize);
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
+			     req->rq_import->imp_connect_data.ocd_max_easize);
 
 	ptlrpc_request_set_replen(req);
 	return req;
@@ -352,6 +354,8 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 	req_capsule_set_size(&req->rq_pill, &RMF_EAVALS_LENS,
 			     RCL_SERVER, maxdata);
 
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, maxdata);
+
 	ptlrpc_request_set_replen(req);
 
 	return req;
@@ -433,6 +437,8 @@ static struct ptlrpc_request *mdc_intent_getattr_pack(struct obd_export *exp,
 	mdc_getattr_pack(req, valid, it->it_flags, op_data, easize);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER, easize);
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
+			     req->rq_import->imp_connect_data.ocd_max_easize);
 	ptlrpc_request_set_replen(req);
 	return req;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 94ab43b..e77c00d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -134,6 +134,8 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 		       LTIME_S(op_data->op_attr.ia_ctime));
 	mdc_setattr_pack(req, op_data, ea, ealen);
 
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
+			     req->rq_import->imp_connect_data.ocd_max_easize);
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_reint(req, LUSTRE_IMP_FULL);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 0f33e34..be374d5 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -183,6 +183,8 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid,
 		      op_data->op_mode, -1, 0);
 
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
+			     req->rq_import->imp_connect_data.ocd_max_easize);
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     op_data->op_mode);
 	ptlrpc_request_set_replen(req);
@@ -229,6 +231,8 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     op_data->op_mode);
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
+			     req->rq_import->imp_connect_data.ocd_max_easize);
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_getattr_common(exp, req);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 2855f38..417d4a1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -992,9 +992,7 @@ struct req_msg_field RMF_EADATA = DEFINE_MSGF("eadata", 0, -1,
 struct req_msg_field RMF_EAVALS = DEFINE_MSGF("eavals", 0, -1, NULL, NULL);
 EXPORT_SYMBOL(RMF_EAVALS);
 
-struct req_msg_field RMF_ACL =
-	DEFINE_MSGF("acl", RMF_F_NO_SIZE_CHECK,
-		    LUSTRE_POSIX_ACL_MAX_SIZE, NULL, NULL);
+struct req_msg_field RMF_ACL = DEFINE_MSGF("acl", 0, -1, NULL, NULL);
 EXPORT_SYMBOL(RMF_ACL);
 
 /* FIXME: this should be made to use RMF_F_STRUCT_ARRAY */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 2f64eb4..f9394c3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1010,8 +1010,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT_ACL);
 	LASSERTF(OBD_CONNECT_XATTR == 0x100ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_XATTR);
-	LASSERTF(OBD_CONNECT_CROW == 0x200ULL, "found 0x%.16llxULL\n",
-		 OBD_CONNECT_CROW);
+	LASSERTF(OBD_CONNECT_LARGE_ACL == 0x200ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT_LARGE_ACL);
 	LASSERTF(OBD_CONNECT_TRUNCLOCK == 0x400ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_TRUNCLOCK);
 	LASSERTF(OBD_CONNECT_TRANSNO == 0x800ULL, "found 0x%.16llxULL\n",
-- 
1.8.3.1
