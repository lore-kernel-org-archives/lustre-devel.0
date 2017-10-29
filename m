From: Roman Storozhenko <romeusmeister@gmail.com>
Date: Sun, 29 Oct 2017 20:58:39 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: Replaces 'uint32_t' with
 '__u32' and 'uint64_t' with '__u64'.
Message-ID: <20171029175839.GA19864@home>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There are two reasons for that:
1) As Linus Torvalds said we should use kernel types:
http://lkml.iu.edu/hypermail//linux/kernel/1506.0/00160.html

2) There are only few places in the lustre codebase that use such types.
In the most cases it uses '__u32' and '__u64'.

Signed-off-by: Roman Storozhenko <romeusmeister@gmail.com>

---
 drivers/staging/lustre/lustre/include/lustre_sec.h |  4 ++--
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  2 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   | 12 ++++++------
 drivers/staging/lustre/lustre/osc/osc_internal.h   |  6 +++---
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index 03a970b..c616ae5 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -340,8 +340,8 @@ void sptlrpc_conf_client_adapt(struct obd_device *obd);
 #define SPTLRPC_MAX_PAYLOAD     (1024)
 
 struct vfs_cred {
-	uint32_t	vc_uid;
-	uint32_t	vc_gid;
+	__u32	vc_uid;
+	__u32	vc_gid;
 };
 
 struct ptlrpc_ctx_ops {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index f9d9a16..9a98a95 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -383,7 +383,7 @@ int cl_sb_fini(struct super_block *sb)
 struct vvp_pgcache_id {
 	unsigned int		 vpi_bucket;
 	unsigned int		 vpi_depth;
-	uint32_t		 vpi_index;
+	__u32			 vpi_index;
 
 	unsigned int		 vpi_curdep;
 	struct lu_object_header *vpi_obj;
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index a21f074..49a106c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -114,19 +114,19 @@ static inline const struct lsm_operations *lsm_op_find(int magic)
  */
 #if BITS_PER_LONG == 64
 # define lov_do_div64(n, base) ({					\
-	uint64_t __base = (base);					\
-	uint64_t __rem;							\
-	__rem = ((uint64_t)(n)) % __base;				\
-	(n) = ((uint64_t)(n)) / __base;					\
+	__u64 __base = (base);						\
+	__u64 __rem;							\
+	__rem = ((__u64)(n)) % __base;				\
+	(n) = ((__u64)(n)) / __base;					\
 	__rem;								\
 })
 #elif BITS_PER_LONG == 32
 # define lov_do_div64(n, base) ({					\
-	uint64_t __rem;							\
+	__u64 __rem;							\
 	if ((sizeof(base) > 4) && (((base) & 0xffffffff00000000ULL) != 0)) {  \
 		int __remainder;					      \
 		LASSERTF(!((base) & (LOV_MIN_STRIPE_SIZE - 1)), "64 bit lov " \
-			 "division %llu / %llu\n", (n), (uint64_t)(base));    \
+			 "division %llu / %llu\n", (n), (__u64)(base));    \
 		__remainder = (n) & (LOV_MIN_STRIPE_SIZE - 1);		\
 		(n) >>= LOV_MIN_STRIPE_BITS;				\
 		__rem = do_div(n, (base) >> LOV_MIN_STRIPE_BITS);	\
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index a536908..92d2e1f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -167,9 +167,9 @@ struct osc_device {
 
 	/* Write stats is actually protected by client_obd's lock. */
 	struct osc_stats {
-		uint64_t     os_lockless_writes;	  /* by bytes */
-		uint64_t     os_lockless_reads;	   /* by bytes */
-		uint64_t     os_lockless_truncates;       /* by times */
+		__u64     os_lockless_writes;	  /* by bytes */
+		__u64     os_lockless_reads;	   /* by bytes */
+		__u64     os_lockless_truncates;       /* by times */
 	} od_stats;
 
 	/* configuration item(s) */
-- 
2.7.4
