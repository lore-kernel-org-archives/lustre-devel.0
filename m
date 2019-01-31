From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:11 -0500
Subject: [lustre-devel] [PATCH 07/26] obdclass: use kernel types for kernel
 code
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre obdclass code was originally both a user land and kernel
implementation. The source contains many types of the form __u32
but since this is mostly kernel code change the types to kernel
internal types.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  2 +-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |  2 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c | 14 +++----
 drivers/staging/lustre/lustre/obdclass/debug.c     | 16 ++++----
 drivers/staging/lustre/lustre/obdclass/genops.c    | 10 ++---
 drivers/staging/lustre/lustre/obdclass/llog_swab.c | 14 +++----
 .../lustre/lustre/obdclass/lprocfs_counters.c      |  2 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        | 46 +++++++++++-----------
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 26 ++++++------
 .../lustre/lustre/obdclass/lustre_handles.c        |  4 +-
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |  4 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  4 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  8 ++--
 14 files changed, 77 insertions(+), 77 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 84c7710..d3f2455 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -205,7 +205,7 @@ int cl_io_rw_init(const struct lu_env *env, struct cl_io *io,
 
 	LU_OBJECT_HEADER(D_VFSTRACE, env, &io->ci_obj->co_lu,
 			 "io range: %u [%llu, %llu) %u %u\n",
-			 iot, (__u64)pos, (__u64)pos + count,
+			 iot, (u64)pos, (u64)pos + count,
 			 io->u.ci_rw.crw_nonblock, io->u.ci_wr.wr_append);
 	io->u.ci_rw.crw_pos    = pos;
 	io->u.ci_rw.crw_count  = count;
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 23c1609..425ca9c 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -180,7 +180,7 @@ int cl_lock_request(const struct lu_env *env, struct cl_io *io,
 		    struct cl_lock *lock)
 {
 	struct cl_sync_io *anchor = NULL;
-	__u32 enq_flags = lock->cll_descr.cld_enq_flags;
+	u32 enq_flags = lock->cll_descr.cld_enq_flags;
 	int rc;
 
 	rc = cl_lock_init(env, lock, io);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index b2bf570..5b59a71 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -592,7 +592,7 @@ static void cl_env_init0(struct cl_env *cle, void *debug)
 	cl_env_inc(CS_busy);
 }
 
-static struct lu_env *cl_env_new(__u32 ctx_tags, __u32 ses_tags, void *debug)
+static struct lu_env *cl_env_new(u32 ctx_tags, u32 ses_tags, void *debug)
 {
 	struct lu_env *env;
 	struct cl_env *cle;
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 75345dd..e130cf7 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -120,7 +120,7 @@ int lustre_get_jobid(char *jobid)
 }
 EXPORT_SYMBOL(lustre_get_jobid);
 
-static int class_resolve_dev_name(__u32 len, const char *name)
+static int class_resolve_dev_name(u32 len, const char *name)
 {
 	int rc;
 	int dev;
@@ -594,19 +594,19 @@ static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 
 static int obd_init_checks(void)
 {
-	__u64 u64val, div64val;
+	u64 u64val, div64val;
 	char buf[64];
 	int len, ret = 0;
 
 	CDEBUG(D_INFO, "LPU64=%s, LPD64=%s, LPX64=%s\n", "%llu", "%lld",
 	       "%#llx");
 
-	CDEBUG(D_INFO, "OBD_OBJECT_EOF = %#llx\n", (__u64)OBD_OBJECT_EOF);
+	CDEBUG(D_INFO, "OBD_OBJECT_EOF = %#llx\n", (u64)OBD_OBJECT_EOF);
 
 	u64val = OBD_OBJECT_EOF;
 	CDEBUG(D_INFO, "u64val OBD_OBJECT_EOF = %#llx\n", u64val);
 	if (u64val != OBD_OBJECT_EOF) {
-		CERROR("__u64 %#llx(%d) != 0xffffffffffffffff\n",
+		CERROR("u64 %#llx(%d) != 0xffffffffffffffff\n",
 		       u64val, (int)sizeof(u64val));
 		ret = -EINVAL;
 	}
@@ -619,12 +619,12 @@ static int obd_init_checks(void)
 	div64val = OBD_OBJECT_EOF;
 	CDEBUG(D_INFO, "u64val OBD_OBJECT_EOF = %#llx\n", u64val);
 	if (u64val != OBD_OBJECT_EOF) {
-		CERROR("__u64 %#llx(%d) != 0xffffffffffffffff\n",
+		CERROR("u64 %#llx(%d) != 0xffffffffffffffff\n",
 		       u64val, (int)sizeof(u64val));
 		ret = -EOVERFLOW;
 	}
 	if (u64val >> 8 != OBD_OBJECT_EOF >> 8) {
-		CERROR("__u64 %#llx(%d) != 0xffffffffffffffff\n",
+		CERROR("u64 %#llx(%d) != 0xffffffffffffffff\n",
 		       u64val, (int)sizeof(u64val));
 		return -EOVERFLOW;
 	}
@@ -654,7 +654,7 @@ static int obd_init_checks(void)
 	}
 	if ((u64val & ~PAGE_MASK) >= PAGE_SIZE) {
 		CWARN("mask failed: u64val %llu >= %llu\n", u64val,
-		      (__u64)PAGE_SIZE);
+		      (u64)PAGE_SIZE);
 		ret = -EINVAL;
 	}
 
diff --git a/drivers/staging/lustre/lustre/obdclass/debug.c b/drivers/staging/lustre/lustre/obdclass/debug.c
index 2156a82..2e526c7 100644
--- a/drivers/staging/lustre/lustre/obdclass/debug.c
+++ b/drivers/staging/lustre/lustre/obdclass/debug.c
@@ -43,8 +43,8 @@
 #include <lustre_debug.h>
 #include <lustre_net.h>
 
-#define LPDS sizeof(__u64)
-int block_debug_setup(void *addr, int len, __u64 off, __u64 id)
+#define LPDS sizeof(u64)
+int block_debug_setup(void *addr, int len, u64 off, u64 id)
 {
 	LASSERT(addr);
 
@@ -58,9 +58,9 @@ int block_debug_setup(void *addr, int len, __u64 off, __u64 id)
 }
 EXPORT_SYMBOL(block_debug_setup);
 
-int block_debug_check(char *who, void *addr, int end, __u64 off, __u64 id)
+int block_debug_check(char *who, void *addr, int end, u64 off, u64 id)
 {
-	__u64 ne_off;
+	u64 ne_off;
 	int err = 0;
 
 	LASSERT(addr);
@@ -69,24 +69,24 @@ int block_debug_check(char *who, void *addr, int end, __u64 off, __u64 id)
 	id = le64_to_cpu(id);
 	if (memcmp(addr, (char *)&ne_off, LPDS)) {
 		CDEBUG(D_ERROR, "%s: id %#llx offset %llu off: %#llx != %#llx\n",
-		       who, id, off, *(__u64 *)addr, ne_off);
+		       who, id, off, *(u64 *)addr, ne_off);
 		err = -EINVAL;
 	}
 	if (memcmp(addr + LPDS, (char *)&id, LPDS)) {
 		CDEBUG(D_ERROR, "%s: id %#llx offset %llu id: %#llx != %#llx\n",
-		       who, id, off, *(__u64 *)(addr + LPDS), id);
+		       who, id, off, *(u64 *)(addr + LPDS), id);
 		err = -EINVAL;
 	}
 
 	addr += end - LPDS - LPDS;
 	if (memcmp(addr, (char *)&ne_off, LPDS)) {
 		CDEBUG(D_ERROR, "%s: id %#llx offset %llu end off: %#llx != %#llx\n",
-		       who, id, off, *(__u64 *)addr, ne_off);
+		       who, id, off, *(u64 *)addr, ne_off);
 		err = -EINVAL;
 	}
 	if (memcmp(addr + LPDS, (char *)&id, LPDS)) {
 		CDEBUG(D_ERROR, "%s: id %#llx offset %llu end id: %#llx != %#llx\n",
-		       who, id, off, *(__u64 *)(addr + LPDS), id);
+		       who, id, off, *(u64 *)(addr + LPDS), id);
 		err = -EINVAL;
 	}
 
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 03df181..3d4d6e1 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -1366,17 +1366,17 @@ void obd_put_request_slot(struct client_obd *cli)
 }
 EXPORT_SYMBOL(obd_put_request_slot);
 
-__u32 obd_get_max_rpcs_in_flight(struct client_obd *cli)
+u32 obd_get_max_rpcs_in_flight(struct client_obd *cli)
 {
 	return cli->cl_max_rpcs_in_flight;
 }
 EXPORT_SYMBOL(obd_get_max_rpcs_in_flight);
 
-int obd_set_max_rpcs_in_flight(struct client_obd *cli, __u32 max)
+int obd_set_max_rpcs_in_flight(struct client_obd *cli, u32 max)
 {
 	struct obd_request_slot_waiter *orsw;
 	const char *typ_name;
-	__u32 old;
+	u32 old;
 	int diff;
 	int rc;
 	int i;
@@ -1424,7 +1424,7 @@ int obd_set_max_rpcs_in_flight(struct client_obd *cli, __u32 max)
 }
 EXPORT_SYMBOL(obd_set_max_rpcs_in_flight);
 
-int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, __u16 max)
+int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, u16 max)
 {
 	struct obd_connect_data *ocd;
 	u16 maxmodrpcs;
@@ -1564,7 +1564,7 @@ static inline bool obd_skip_mod_rpc_slot(const struct lookup_intent *it)
  * Returns the tag to be set in the request message. Tag 0
  * is reserved for non-modifying requests.
  */
-u16 obd_get_mod_rpc_slot(struct client_obd *cli, __u32 opc,
+u16 obd_get_mod_rpc_slot(struct client_obd *cli, u32 opc,
 			 struct lookup_intent *it)
 {
 	bool close_req = false;
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index f18330f..fddc1ea 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -358,12 +358,12 @@ void lustre_swab_lustre_cfg(struct lustre_cfg *lcfg)
 
 /* used only for compatibility with old on-disk cfg_marker data */
 struct cfg_marker32 {
-	__u32   cm_step;
-	__u32   cm_flags;
-	__u32   cm_vers;
-	__u32   padding;
-	__u32   cm_createtime;
-	__u32   cm_canceltime;
+	u32   cm_step;
+	u32   cm_flags;
+	u32   cm_vers;
+	u32   padding;
+	u32   cm_createtime;
+	u32   cm_canceltime;
 	char    cm_tgtname[MTI_NAME_MAXLEN];
 	char    cm_comment[MTI_NAME_MAXLEN];
 };
@@ -381,7 +381,7 @@ void lustre_swab_cfg_marker(struct cfg_marker *marker, int swab, int size)
 		__swab32s(&marker->cm_vers);
 	}
 	if (size == sizeof(*cm32)) {
-		__u32 createtime, canceltime;
+		u32 createtime, canceltime;
 		/* There was a problem with the original declaration of
 		 * cfg_marker on 32-bit systems because it used time_t as
 		 * a wire protocol structure, and didn't verify this in
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
index 85f09af..77bc66f 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
@@ -82,7 +82,7 @@ void lprocfs_counter_add(struct lprocfs_stats *stats, int idx, long amount)
 			percpu_cntr->lc_sum += amount;
 
 		if (header->lc_config & LPROCFS_CNTR_STDDEV)
-			percpu_cntr->lc_sumsquare += (__s64)amount * amount;
+			percpu_cntr->lc_sumsquare += (s64)amount * amount;
 		if (amount < percpu_cntr->lc_min)
 			percpu_cntr->lc_min = amount;
 		if (amount > percpu_cntr->lc_max)
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index acfea7a..cc70402 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -118,7 +118,7 @@
 int obd_connect_flags2str(char *page, int count, u64 flags, u64 flags2,
 			  const char *sep)
 {
-	__u64 mask;
+	u64 mask;
 	int i, ret = 0;
 
 	BUILD_BUG_ON(ARRAY_SIZE(obd_connect_names) < 65);
@@ -385,8 +385,8 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 			    OBD_STATFS_NODELAY);
 	if (!rc) {
-		__u32 blk_size = osfs.os_bsize >> 10;
-		__u64 result = osfs.os_blocks;
+		u32 blk_size = osfs.os_bsize >> 10;
+		u64 result = osfs.os_blocks;
 
 		while (blk_size >>= 1)
 			result <<= 1;
@@ -408,8 +408,8 @@ static ssize_t kbytesfree_show(struct kobject *kobj, struct attribute *attr,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 			    OBD_STATFS_NODELAY);
 	if (!rc) {
-		__u32 blk_size = osfs.os_bsize >> 10;
-		__u64 result = osfs.os_bfree;
+		u32 blk_size = osfs.os_bsize >> 10;
+		u64 result = osfs.os_bfree;
 
 		while (blk_size >>= 1)
 			result <<= 1;
@@ -431,8 +431,8 @@ static ssize_t kbytesavail_show(struct kobject *kobj, struct attribute *attr,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 			    OBD_STATFS_NODELAY);
 	if (!rc) {
-		__u32 blk_size = osfs.os_bsize >> 10;
-		__u64 result = osfs.os_bavail;
+		u32 blk_size = osfs.os_bsize >> 10;
+		u64 result = osfs.os_bavail;
 
 		while (blk_size >>= 1)
 			result <<= 1;
@@ -702,7 +702,7 @@ static int obd_import_flags2str(struct obd_import *imp, struct seq_file *m)
 static void obd_connect_seq_flags2str(struct seq_file *m, u64 flags,
 				      u64 flags2, const char *sep)
 {
-	__u64 mask;
+	u64 mask;
 	int i;
 	bool first = true;
 
@@ -813,8 +813,8 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 	header = &obd->obd_svc_stats->ls_cnt_header[PTLRPC_REQWAIT_CNTR];
 	lprocfs_stats_collect(obd->obd_svc_stats, PTLRPC_REQWAIT_CNTR, &ret);
 	if (ret.lc_count != 0) {
-		/* first argument to do_div MUST be __u64 */
-		__u64 sum = ret.lc_sum;
+		/* first argument to do_div MUST be u64 */
+		u64 sum = ret.lc_sum;
 
 		do_div(sum, ret.lc_count);
 		ret.lc_sum = sum;
@@ -861,8 +861,8 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 				      PTLRPC_LAST_CNTR + BRW_READ_BYTES + rw,
 				      &ret);
 		if (ret.lc_sum > 0 && ret.lc_count > 0) {
-			/* first argument to do_div MUST be __u64 */
-			__u64 sum = ret.lc_sum;
+			/* first argument to do_div MUST be u64 */
+			u64 sum = ret.lc_sum;
 
 			do_div(sum, ret.lc_count);
 			ret.lc_sum = sum;
@@ -877,8 +877,8 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		header = &obd->obd_svc_stats->ls_cnt_header[j];
 		lprocfs_stats_collect(obd->obd_svc_stats, j, &ret);
 		if (ret.lc_sum > 0 && ret.lc_count != 0) {
-			/* first argument to do_div MUST be __u64 */
-			__u64 sum = ret.lc_sum;
+			/* first argument to do_div MUST be u64 */
+			u64 sum = ret.lc_sum;
 
 			do_div(sum, ret.lc_count);
 			ret.lc_sum = sum;
@@ -994,7 +994,7 @@ int lprocfs_rd_timeouts(struct seq_file *m, void *data)
 int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
 {
 	struct obd_device *obd = data;
-	__u64 flags, flags2;
+	u64 flags, flags2;
 	int rc;
 
 	rc = lprocfs_climp_check(obd);
@@ -1217,13 +1217,13 @@ void lprocfs_free_stats(struct lprocfs_stats **statsh)
 }
 EXPORT_SYMBOL(lprocfs_free_stats);
 
-__u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
+u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
 			      enum lprocfs_fields_flags field)
 {
 	unsigned int i;
 	unsigned int  num_cpu;
 	unsigned long flags     = 0;
-	__u64         ret       = 0;
+	u64         ret       = 0;
 
 	LASSERT(stats);
 
@@ -1471,12 +1471,12 @@ void ldebugfs_free_md_stats(struct obd_device *obd)
 }
 EXPORT_SYMBOL(ldebugfs_free_md_stats);
 
-__s64 lprocfs_read_helper(struct lprocfs_counter *lc,
+s64 lprocfs_read_helper(struct lprocfs_counter *lc,
 			  struct lprocfs_counter_header *header,
 			  enum lprocfs_stats_flags flags,
 			  enum lprocfs_fields_flags field)
 {
-	__s64 ret = 0;
+	s64 ret = 0;
 
 	if (!lc || !header)
 		return 0;
@@ -1521,17 +1521,17 @@ int lprocfs_write_helper(const char __user *buffer, unsigned long count,
 EXPORT_SYMBOL(lprocfs_write_helper);
 
 int lprocfs_write_u64_helper(const char __user *buffer, unsigned long count,
-			     __u64 *val)
+			     u64 *val)
 {
 	return lprocfs_write_frac_u64_helper(buffer, count, val, 1);
 }
 EXPORT_SYMBOL(lprocfs_write_u64_helper);
 
 int lprocfs_write_frac_u64_helper(const char __user *buffer,
-				  unsigned long count, __u64 *val, int mult)
+				  unsigned long count, u64 *val, int mult)
 {
 	char kernbuf[22], *end, *pbuf;
-	__u64 whole, frac = 0, units;
+	u64 whole, frac = 0, units;
 	unsigned int frac_d = 1;
 	int sign = 1;
 
@@ -1557,7 +1557,7 @@ int lprocfs_write_frac_u64_helper(const char __user *buffer,
 
 		pbuf = end + 1;
 
-		/* need to limit frac_d to a __u32 */
+		/* need to limit frac_d to a u32 */
 		if (strlen(pbuf) > 10)
 			pbuf[10] = '\0';
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index c513e55..a132d87 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -106,7 +106,7 @@ enum {
 MODULE_PARM_DESC(lu_cache_nr, "Maximum number of objects in lu_object cache");
 
 static void lu_object_free(const struct lu_env *env, struct lu_object *o);
-static __u32 ls_stats_read(struct lprocfs_stats *stats, int idx);
+static u32 ls_stats_read(struct lprocfs_stats *stats, int idx);
 
 wait_queue_head_t *
 lu_site_wq_from_fid(struct lu_site *site, struct lu_fid *fid)
@@ -590,7 +590,7 @@ void lu_object_print(const struct lu_env *env, void *cookie,
 static struct lu_object *htable_lookup(struct lu_site *s,
 				       struct cfs_hash_bd *bd,
 				       const struct lu_fid *f,
-				       __u64 *version)
+				       u64 *version)
 {
 	struct lu_site_bkt_data *bkt;
 	struct lu_object_header *h;
@@ -643,18 +643,18 @@ static struct lu_object *lu_object_find(const struct lu_env *env,
  */
 static void lu_object_limit(const struct lu_env *env, struct lu_device *dev)
 {
-	__u64 size, nr;
+	u64 size, nr;
 
 	if (lu_cache_nr == LU_CACHE_NR_UNLIMITED)
 		return;
 
 	size = cfs_hash_size_get(dev->ld_site->ls_obj_hash);
-	nr = (__u64)lu_cache_nr;
+	nr = (u64)lu_cache_nr;
 	if (size <= nr)
 		return;
 
 	lu_site_purge_objects(env, dev->ld_site,
-			      min_t(__u64, size - nr, LU_CACHE_NR_MAX_ADJUST),
+			      min_t(u64, size - nr, LU_CACHE_NR_MAX_ADJUST),
 			      false);
 }
 
@@ -675,7 +675,7 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	struct lu_site	*s;
 	struct cfs_hash	    *hs;
 	struct cfs_hash_bd	  bd;
-	__u64		  version = 0;
+	u64		  version = 0;
 
 	/*
 	 * This uses standard index maintenance protocol:
@@ -884,7 +884,7 @@ static unsigned int lu_obj_hop_hash(struct cfs_hash *hs,
 				    const void *key, unsigned int mask)
 {
 	struct lu_fid  *fid = (struct lu_fid *)key;
-	__u32	   hash;
+	u32	   hash;
 
 	hash = fid_flatten32(fid);
 	hash += (hash >> 4) + (hash << 12); /* mixing oid and seq */
@@ -1593,7 +1593,7 @@ static int keys_init(struct lu_context *ctx)
 /**
  * Initialize context data-structure. Create values for all keys.
  */
-int lu_context_init(struct lu_context *ctx, __u32 tags)
+int lu_context_init(struct lu_context *ctx, u32 tags)
 {
 	int	rc;
 
@@ -1705,10 +1705,10 @@ int lu_context_refill(struct lu_context *ctx)
  * predefined when the lu_device type are registered, during the module probe
  * phase.
  */
-__u32 lu_context_tags_default;
-__u32 lu_session_tags_default;
+u32 lu_context_tags_default;
+u32 lu_session_tags_default;
 
-int lu_env_init(struct lu_env *env, __u32 tags)
+int lu_env_init(struct lu_env *env, u32 tags)
 {
 	int result;
 
@@ -1939,12 +1939,12 @@ void lu_global_fini(void)
 	lu_ref_global_fini();
 }
 
-static __u32 ls_stats_read(struct lprocfs_stats *stats, int idx)
+static u32 ls_stats_read(struct lprocfs_stats *stats, int idx)
 {
 	struct lprocfs_counter ret;
 
 	lprocfs_stats_collect(stats, idx, &ret);
-	return (__u32)ret.lc_count;
+	return (u32)ret.lc_count;
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index cdc8dc1..b296877 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -42,7 +42,7 @@
 #include <lustre_handles.h>
 #include <lustre_lib.h>
 
-static __u64 handle_base;
+static u64 handle_base;
 #define HANDLE_INCR 7
 static spinlock_t handle_base_lock;
 
@@ -132,7 +132,7 @@ void class_handle_unhash(struct portals_handle *h)
 }
 EXPORT_SYMBOL(class_handle_unhash);
 
-void *class_handle2object(__u64 cookie, const void *owner)
+void *class_handle2object(u64 cookie, const void *owner)
 {
 	struct handle_bucket *bucket;
 	struct portals_handle *h;
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index 5705b0a..8e7f3a8 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -80,7 +80,7 @@ int lustre_uuid_to_peer(const char *uuid, lnet_nid_t *peer_nid, int index)
 /* Add a nid to a niduuid.  Multiple nids can be added to a single uuid;
  * LNET will choose the best one.
  */
-int class_add_uuid(const char *uuid, __u64 nid)
+int class_add_uuid(const char *uuid, u64 nid)
 {
 	struct uuid_nid_data *data, *entry;
 	int found = 0;
@@ -173,7 +173,7 @@ int class_del_uuid(const char *uuid)
 }
 
 /* check if @nid exists in nid list of @uuid */
-int class_check_uuid(struct obd_uuid *uuid, __u64 nid)
+int class_check_uuid(struct obd_uuid *uuid, u64 nid)
 {
 	struct uuid_nid_data *entry;
 	int found = 0;
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 7d00ca4..887afda 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -168,7 +168,7 @@ static int parse_nid(char *buf, void *value, int quiet)
 
 static int parse_net(char *buf, void *value)
 {
-	__u32 *net = value;
+	u32 *net = value;
 
 	*net = libcfs_str2net(buf);
 	CDEBUG(D_INFO, "Net %s\n", libcfs_net2str(*net));
@@ -1415,7 +1415,7 @@ int class_config_llog_handler(const struct lu_env *env,
 		 */
 		if (lcfg->lcfg_nal != 0 &&      /* pre-newconfig log? */
 		    (lcfg->lcfg_nid >> 32) == 0) {
-			__u32 addr = (__u32)(lcfg->lcfg_nid & 0xffffffff);
+			u32 addr = (u32)(lcfg->lcfg_nid & 0xffffffff);
 
 			lcfg_new->lcfg_nid =
 				LNET_MKNID(LNET_MKNET(lcfg->lcfg_nal, 0), addr);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index db5e1b5..eab3216 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -269,7 +269,7 @@ int lustre_start_mgc(struct super_block *sb)
 		if (lmd_is_client(lsi->lsi_lmd)) {
 			int has_ir;
 			int vallen = sizeof(*data);
-			__u32 *flags = &lsi->lsi_lmd->lmd_flags;
+			u32 *flags = &lsi->lsi_lmd->lmd_flags;
 
 			rc = obd_get_info(NULL, obd->obd_self_export,
 					  strlen(KEY_CONN_DATA), KEY_CONN_DATA,
@@ -621,7 +621,7 @@ static int server_name2fsname(const char *svname, char *fsname,
  * rc < 0  on error
  * if endptr isn't NULL it is set to end of name
  */
-static int server_name2index(const char *svname, __u32 *idx,
+static int server_name2index(const char *svname, u32 *idx,
 			     const char **endptr)
 {
 	unsigned long index;
@@ -721,7 +721,7 @@ int lustre_check_exclusion(struct super_block *sb, char *svname)
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct lustre_mount_data *lmd = lsi->lsi_lmd;
-	__u32 index;
+	u32 index;
 	int i, rc;
 
 	rc = server_name2index(svname, &index, NULL);
@@ -745,7 +745,7 @@ int lustre_check_exclusion(struct super_block *sb, char *svname)
 static int lmd_make_exclusion(struct lustre_mount_data *lmd, const char *ptr)
 {
 	const char *s1 = ptr, *s2;
-	__u32 index = 0, *exclude_list;
+	u32 index = 0, *exclude_list;
 	int rc = 0, devmax;
 
 	/* The shortest an ost name can be is 8 chars: -OST0000.
-- 
1.8.3.1
