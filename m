From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:26 -0400
Subject: [lustre-devel] [PATCH 09/18] lustre: llite: ladvise protocol changes
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <paf@cray.com>

This patch makes some changes to the ladvise API and
protocol to support lock ahead and possible future users.

Primarily, it separates the userspace API arguments from
the structures which go out on the network, and adds a
number of 'value' fields without a predefined use.

The meaning of each value field can be different for
different advice types, allowing some extensibility.

Signed-off-by: Patrick Farrell <paf@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7225
Reviewed-on: http://review.whamcloud.com/20666
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  | 30 ++++++++++++++++
 .../lustre/include/uapi/linux/lustre/lustre_user.h | 37 +++++++++++++------
 drivers/staging/lustre/lustre/llite/file.c         |  8 ++---
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 12 ++++---
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 42 +++++++++++++++-------
 5 files changed, 97 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 4e25521..029ac8e 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -2694,5 +2694,35 @@ struct close_data {
 	__u64			cd_reserved[8];
 };
 
+/*
+ * This is the lu_ladvise struct which goes out on the wire.
+ * Corresponds to the userspace arg llapi_lu_ladvise.
+ * value[1-4] are unspecified fields, used differently by different advices
+ */
+struct lu_ladvise {
+	__u16 lla_advice;	/* advice type */
+	__u16 lla_value1;	/* values for different advice types */
+	__u32 lla_value2;
+	__u64 lla_start;	/* first byte of extent for advice */
+	__u64 lla_end;		/* last byte of extent for advice */
+	__u32 lla_value3;
+	__u32 lla_value4;
+};
+
+/*
+ * This is the ladvise_hdr which goes on the wire, corresponds to the userspace
+ * arg llapi_ladvise_hdr.
+ * value[1-3] are unspecified fields, used differently by different advices
+ */
+struct ladvise_hdr {
+	__u32			lah_magic;	/* LADVISE_MAGIC */
+	__u32			lah_count;	/* number of advices */
+	__u64			lah_flags;	/* from enum ladvise_flag */
+	__u32			lah_value1;	/* unused */
+	__u32			lah_value2;	/* unused */
+	__u64			lah_value3;	/* unused */
+	struct lu_ladvise	lah_advise[0];	/* advices in this header */
+};
+
 #endif
 /** @} lustreidl */
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index fc33a43..063a7db 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -276,7 +276,7 @@ struct ost_id {
 #define LL_IOC_MIGRATE			_IOR('f', 247, int)
 #define LL_IOC_FID2MDTIDX		_IOWR('f', 248, struct lu_fid)
 #define LL_IOC_GETPARENT		_IOWR('f', 249, struct getparent)
-#define LL_IOC_LADVISE			_IOR('f', 250, struct lu_ladvise)
+#define LL_IOC_LADVISE			_IOR('f', 250, struct llapi_lu_ladvise)
 
 /* Lease types for use as arg and return of LL_IOC_{GET,SET}_LEASE ioctl. */
 enum ll_lease_type {
@@ -1327,13 +1327,22 @@ enum lu_ladvise_type {
 	LU_LADVISE_INVALID	= 0,
 };
 
-#define LU_LADVISE_NAMES { }
+#define LU_LADVISE_NAMES {				\
+}
 
-struct lu_ladvise {
-	__u64			lla_advice;
-	__u64			lla_start;
-	__u64			lla_end;
-	__u64			lla_padding;
+/*
+ * This is the userspace argument for ladvise. It is currently the same as
+ * what goes on the wire (struct lu_ladvise), but is defined separately as we
+ * may need info which is only used locally.
+ */
+struct llapi_lu_ladvise {
+	__u16 lla_advice;	/* advice type */
+	__u16 lla_value1;	/* values for different advice types */
+	__u32 lla_value2;
+	__u64 lla_start;	/* first byte of extent for advice */
+	__u64 lla_end;		/* last byte of extent for advice */
+	__u32 lla_value3;
+	__u32 lla_value4;
 };
 
 enum ladvise_flag {
@@ -1343,13 +1352,19 @@ enum ladvise_flag {
 #define LADVISE_MAGIC 0x1ADF1CE0
 #define LF_MASK LF_ASYNC
 
-struct ladvise_hdr {
+/*
+ * This is the userspace argument for ladvise, corresponds to ladvise_hdr which
+ * is used on the wire. It is defined separately as we may need info which is
+ * only used locally.
+ */
+struct llapi_ladvise_hdr {
 	__u32			lah_magic;	/* LADVISE_MAGIC */
 	__u32			lah_count;	/* number of advices */
 	__u64			lah_flags;	/* from enum ladvise_flag */
-	__u64			lah_padding1;	/* unused */
-	__u64			lah_padding2;	/* unused */
-	struct lu_ladvise	lah_advise[0];
+	__u32			lah_value1;	/* unused */
+	__u32			lah_value2;	/* unused */
+	__u64			lah_value3;	/* unused */
+	struct llapi_lu_ladvise	lah_advise[0];	/* advices in this header */
 };
 
 #define LAH_COUNT_MAX		1024
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index d570232..5d0f8c2 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2098,7 +2098,7 @@ static inline long ll_lease_type_from_fmode(fmode_t fmode)
  * much more data being sent to the client.
  */
 static int ll_ladvise(struct inode *inode, struct file *file, __u64 flags,
-		      struct lu_ladvise *ladvise)
+		      struct llapi_lu_ladvise *ladvise)
 {
 	struct cl_ladvise_io *lio;
 	struct lu_env *env;
@@ -2458,7 +2458,7 @@ static int ll_ladvise(struct inode *inode, struct file *file, __u64 flags,
 		return rc;
 	}
 	case LL_IOC_LADVISE: {
-		struct ladvise_hdr *ladvise_hdr;
+		struct llapi_ladvise_hdr *ladvise_hdr;
 		int alloc_size = sizeof(*ladvise_hdr);
 		int num_advise;
 		int i;
@@ -2469,7 +2469,7 @@ static int ll_ladvise(struct inode *inode, struct file *file, __u64 flags,
 			return -ENOMEM;
 
 		if (copy_from_user(ladvise_hdr,
-				   (const struct ladvise_hdr __user *)arg,
+				   (const struct llapi_ladvise_hdr __user *)arg,
 				   alloc_size)) {
 			rc = -EFAULT;
 			goto out_ladvise;
@@ -2498,7 +2498,7 @@ static int ll_ladvise(struct inode *inode, struct file *file, __u64 flags,
 		 * TODO: submit multiple advices to one server in a single RPC
 		 */
 		if (copy_from_user(ladvise_hdr,
-				   (const struct ladvise_hdr __user *)arg,
+				   (const struct llapi_advise_hdr __user *)arg,
 				   alloc_size)) {
 			rc = -EFAULT;
 			goto out_ladvise;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 468fa69..86a64a6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -2312,10 +2312,13 @@ void lustre_swab_close_data(struct close_data *cd)
 
 void lustre_swab_ladvise(struct lu_ladvise *ladvise)
 {
+	swab16s(&ladvise->lla_advice);
+	swab16s(&ladvise->lla_value1);
+	swab32s(&ladvise->lla_value2);
 	swab64s(&ladvise->lla_start);
 	swab64s(&ladvise->lla_end);
-	swab64s(&ladvise->lla_advice);
-	BUILD_BUG_ON(!offsetof(typeof(*ladvise), lla_padding));
+	swab32s(&ladvise->lla_value3);
+	swab32s(&ladvise->lla_value4);
 }
 EXPORT_SYMBOL(lustre_swab_ladvise);
 
@@ -2324,7 +2327,8 @@ void lustre_swab_ladvise_hdr(struct ladvise_hdr *ladvise_hdr)
 	swab32s(&ladvise_hdr->lah_magic);
 	swab32s(&ladvise_hdr->lah_count);
 	swab64s(&ladvise_hdr->lah_flags);
-	BUILD_BUG_ON(!offsetof(typeof(*ladvise_hdr), lah_padding1));
-	BUILD_BUG_ON(!offsetof(typeof(*ladvise_hdr), lah_padding2));
+	swab32s(&ladvise_hdr->lah_value1);
+	swab32s(&ladvise_hdr->lah_value2);
+	swab64s(&ladvise_hdr->lah_value3);
 }
 EXPORT_SYMBOL(lustre_swab_ladvise_hdr);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index dae1b09..a1895cb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -4217,8 +4217,16 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)sizeof(struct lu_ladvise));
 	LASSERTF((int)offsetof(struct lu_ladvise, lla_advice) == 0, "found %lld\n",
 		 (long long)(int)offsetof(struct lu_ladvise, lla_advice));
-	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_advice) == 8, "found %lld\n",
+	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_advice) == 2, "found %lld\n",
 		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_advice));
+	LASSERTF((int)offsetof(struct lu_ladvise, lla_value1) == 2, "found %lld\n",
+		 (long long)(int)offsetof(struct lu_ladvise, lla_value1));
+	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_value1) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_value1));
+	LASSERTF((int)offsetof(struct lu_ladvise, lla_value2) == 4, "found %lld\n",
+		 (long long)(int)offsetof(struct lu_ladvise, lla_value2));
+	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_value2) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_value2));
 	LASSERTF((int)offsetof(struct lu_ladvise, lla_start) == 8, "found %lld\n",
 		 (long long)(int)offsetof(struct lu_ladvise, lla_start));
 	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_start) == 8, "found %lld\n",
@@ -4227,10 +4235,14 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lu_ladvise, lla_end));
 	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_end) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_end));
-	LASSERTF((int)offsetof(struct lu_ladvise, lla_padding) == 24, "found %lld\n",
-		 (long long)(int)offsetof(struct lu_ladvise, lla_padding));
-	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_padding) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_padding));
+	LASSERTF((int)offsetof(struct lu_ladvise, lla_value3) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct lu_ladvise, lla_value3));
+	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_value3) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_value3));
+	LASSERTF((int)offsetof(struct lu_ladvise, lla_value4) == 28, "found %lld\n",
+		 (long long)(int)offsetof(struct lu_ladvise, lla_value4));
+	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_value4) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_value4));
 
 	/* Checks for struct ladvise_hdr */
 	LASSERTF(LADVISE_MAGIC == 0x1ADF1CE0, "found 0x%.8x\n",
@@ -4249,14 +4261,18 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct ladvise_hdr, lah_flags));
 	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_flags) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_flags));
-	LASSERTF((int)offsetof(struct ladvise_hdr, lah_padding1) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct ladvise_hdr, lah_padding1));
-	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_padding1) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_padding1));
-	LASSERTF((int)offsetof(struct ladvise_hdr, lah_padding2) == 24, "found %lld\n",
-		 (long long)(int)offsetof(struct ladvise_hdr, lah_padding2));
-	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_padding2) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_padding2));
+	LASSERTF((int)offsetof(struct ladvise_hdr, lah_value1) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct ladvise_hdr, lah_value1));
+	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_value1) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_value1));
+	LASSERTF((int)offsetof(struct ladvise_hdr, lah_value2) == 20, "found %lld\n",
+		 (long long)(int)offsetof(struct ladvise_hdr, lah_value2));
+	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_value2) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_value2));
+	LASSERTF((int)offsetof(struct ladvise_hdr, lah_value3) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct ladvise_hdr, lah_value3));
+	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_value3) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_value3));
 	LASSERTF((int)offsetof(struct ladvise_hdr, lah_advise) == 32, "found %lld\n",
 		 (long long)(int)offsetof(struct ladvise_hdr, lah_advise));
 	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_advise) == 0, "found %lld\n",
-- 
1.8.3.1
