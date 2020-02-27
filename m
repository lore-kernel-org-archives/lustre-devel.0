From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:57 -0500
Subject: [lustre-devel] [PATCH 069/622] lustre: mdt: Lazy size on MDT
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-70-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

The design of Lazy size on MDT (LSOM) does not guarantee the
accuracy. A file that is being opened for a long time might
cause inaccurate LSOM for a very long time. And also eviction or
crash of client might cause incomplete process of closing a file,
thus might cause inaccurate LSOM. A precise LSOM could only be read
from MDT when 1) all possible corruption and inconsistency caused
by client eviction or client/server crash have all been fixed by
LFSCK and 2) the file is not being opened for write.
In the first step of implementing LSOM, LSOM will not be accessible
from client. Instead, LSOM values can only be accessed on MDT. Thus,
no interface or logic codes will be added on client side to enabled
the access of LSOM from client side.
The LSOM will be saved as an EA value on MDT.
LSOM includes both the apparent size and also the disk usage of
the file.
Whenever a file is being truncated, the LSOM of the file on MDT
will be updated.
Whenever a client is closing a file, ll_prepare_close() will send
the size and blocks to the MDS. The MDS will update the LSOM of
the file if the file size or block size is being increased.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9538
Lustre-commit: f1ebf88aef21 ("LU-9538 mdt: Lazy size on MDT")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/29960
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h                 |  4 +++-
 fs/lustre/llite/file.c                  |  5 +++++
 fs/lustre/mdc/mdc_lib.c                 |  4 ++++
 fs/lustre/ptlrpc/wiretest.c             | 24 ++++++++++++++++++++++++
 include/uapi/linux/lustre/lustre_idl.h  |  2 ++
 include/uapi/linux/lustre/lustre_user.h | 17 +++++++++++++++--
 6 files changed, 53 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 5656eb0..c712979 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -204,7 +204,7 @@ struct client_obd {
 	long			cl_reserved_grant;
 	wait_queue_head_t	cl_cache_waiters;	/* waiting for cache/grant */
 	time64_t		cl_next_shrink_grant;	/* seconds */
-	struct list_head	cl_grant_shrink_list;	/* Timeout event list */
+	struct list_head	cl_grant_chain;
 	time64_t		cl_grant_shrink_interval; /* seconds */
 
 	/* A chunk is an optimal size used by osc_extent to determine
@@ -670,6 +670,8 @@ enum op_xvalid {
 	OP_XVALID_OWNEROVERRIDE	= BIT(2),	/* 0x0004 */
 	OP_XVALID_FLAGS		= BIT(3),	/* 0x0008 */
 	OP_XVALID_PROJID	= BIT(4),	/* 0x0010 */
+	OP_XVALID_LAZYSIZE	= BIT(5),	/* 0x0020 */
+	OP_XVALID_LAZYBLOCKS	= BIT(6),	/* 0x0040 */
 };
 
 struct lu_context;
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index c3fb104b..837add1 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -207,6 +207,11 @@ static int ll_close_inode_openhandle(struct inode *inode,
 		break;
 	}
 
+	if (!(op_data->op_attr.ia_valid & ATTR_SIZE))
+		op_data->op_xvalid |= OP_XVALID_LAZYSIZE;
+	if (!(op_data->op_xvalid & OP_XVALID_BLOCKS))
+		op_data->op_xvalid |= OP_XVALID_LAZYBLOCKS;
+
 	rc = md_close(md_exp, op_data, och->och_mod, &req);
 	if (rc && rc != -EINTR) {
 		CERROR("%s: inode " DFID " mdc close failed: rc = %d\n",
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 467503c..e2f1a49 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -317,6 +317,10 @@ static inline u64 attr_pack(unsigned int ia_valid, enum op_xvalid ia_xvalid)
 		sa_valid |= MDS_OPEN_OWNEROVERRIDE;
 	if (ia_xvalid & OP_XVALID_PROJID)
 		sa_valid |= MDS_ATTR_PROJID;
+	if (ia_xvalid & OP_XVALID_LAZYSIZE)
+		sa_valid |= MDS_ATTR_LSIZE;
+	if (ia_xvalid & OP_XVALID_LAZYBLOCKS)
+		sa_valid |= MDS_ATTR_LBLOCKS;
 	return sa_valid;
 }
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 7b6ea86..b4bb30d 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -258,6 +258,10 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(MDS_ATTR_PROJID == 0x0000000000010000ULL, "found 0x%.16llxULL\n",
 		 (long long)MDS_ATTR_PROJID);
 
+	LASSERTF(MDS_ATTR_LSIZE == 0x0000000000020000ULL, "found 0x%.16llxULL\n",
+		 (long long)MDS_ATTR_LSIZE);
+	LASSERTF(MDS_ATTR_LBLOCKS == 0x0000000000040000ULL, "found 0x%.16llxULL\n",
+		 (long long)MDS_ATTR_LBLOCKS);
 	LASSERTF(FLD_QUERY == 900, "found %lld\n",
 		 (long long)FLD_QUERY);
 	LASSERTF(FLD_FIRST_OPC == 900, "found %lld\n",
@@ -390,6 +394,26 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(LU_SEQ_RANGE_OST == 1, "found %lld\n",
 		 (long long)LU_SEQ_RANGE_OST);
 
+	/* Checks for struct lustre_som_attrs */
+	LASSERTF((int)sizeof(struct lustre_som_attrs) == 24, "found %lld\n",
+		 (long long)(int)sizeof(struct lustre_som_attrs));
+	LASSERTF((int)offsetof(struct lustre_som_attrs, lsa_valid) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_som_attrs, lsa_valid));
+	LASSERTF((int)sizeof(((struct lustre_som_attrs *)0)->lsa_valid) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_som_attrs *)0)->lsa_valid));
+	LASSERTF((int)offsetof(struct lustre_som_attrs, lsa_reserved) == 2, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_som_attrs, lsa_reserved));
+	LASSERTF((int)sizeof(((struct lustre_som_attrs *)0)->lsa_reserved) == 6, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_som_attrs *)0)->lsa_reserved));
+	LASSERTF((int)offsetof(struct lustre_som_attrs, lsa_size) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_som_attrs, lsa_size));
+	LASSERTF((int)sizeof(((struct lustre_som_attrs *)0)->lsa_size) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_som_attrs *)0)->lsa_size));
+	LASSERTF((int)offsetof(struct lustre_som_attrs, lsa_blocks) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_som_attrs, lsa_blocks));
+	LASSERTF((int)sizeof(((struct lustre_som_attrs *)0)->lsa_blocks) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_som_attrs *)0)->lsa_blocks));
+
 	/* Checks for struct lustre_mdt_attrs */
 	LASSERTF((int)sizeof(struct lustre_mdt_attrs) == 24, "found %lld\n",
 		 (long long)(int)sizeof(struct lustre_mdt_attrs));
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 5db742f..9f8d65d 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1676,6 +1676,8 @@ struct mdt_rec_setattr {
 					   */
 #define MDS_ATTR_BLOCKS		0x8000ULL  /* = 32768 */
 #define MDS_ATTR_PROJID		0x10000ULL /* = 65536 */
+#define MDS_ATTR_LSIZE		0x20000ULL /* = 131072 */
+#define MDS_ATTR_LBLOCKS	0x40000ULL /* = 262144 */
 
 enum mds_op_bias {
 /*	MDS_CHECK_SPLIT		= 1 << 0, obsolete before 2.3.58 */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 5956f33..b2f5b57 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -202,8 +202,19 @@ struct lustre_mdt_attrs {
  */
 #define LMA_OLD_SIZE (sizeof(struct lustre_mdt_attrs) + 5 * sizeof(__u64))
 
-enum {
-	LSOM_FL_VALID = 1 << 0,
+enum lustre_som_flags {
+	/* Unknown or no SoM data, must get size from OSTs. */
+	SOM_FL_UNKNOWN	= 0x0000,
+	/* Known strictly correct, FLR or DoM file (SoM guaranteed). */
+	SOM_FL_STRICT	= 0x0001,
+	/* Known stale - was right@some point in the past, but it is
+	 * known (or likely) to be incorrect now (e.g. opened for write).
+	 */
+	SOM_FL_STALE	= 0x0002,
+	/* Approximate, may never have been strictly correct,
+	 * need to sync SOM data to achieve eventual consistency.
+	 */
+	SOM_FL_LAZY	= 0x0004,
 };
 
 struct lustre_som_attrs {
@@ -882,6 +893,8 @@ enum la_valid {
 	LA_KILL_SGID	= 1 << 14,
 	LA_PROJID	= 1 << 15,
 	LA_LAYOUT_VERSION = 1 << 16,
+	LA_LSIZE	= 1 << 17,
+	LA_LBLOCKS	= 1 << 18,
 	/**
 	 * Attributes must be transmitted to OST objects
 	 */
-- 
1.8.3.1
