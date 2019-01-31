From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:27 -0500
Subject: [lustre-devel] [PATCH 23/26] libcfs: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The libcfs code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_debug.h     |  74 ++++++------
 .../lustre/include/linux/libcfs/libcfs_fail.h      |   8 +-
 .../lustre/include/linux/libcfs/libcfs_private.h   |  56 ++++-----
 .../lustre/include/linux/libcfs/libcfs_string.h    |  10 +-
 drivers/staging/lustre/lnet/libcfs/debug.c         |  22 ++--
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |   8 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   4 +-
 .../lustre/lnet/libcfs/linux-crypto-adler.c        |   2 +-
 drivers/staging/lustre/lnet/libcfs/linux-crypto.c  |   1 -
 drivers/staging/lustre/lnet/libcfs/module.c        | 128 ++++++++++-----------
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   5 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |  12 +-
 12 files changed, 164 insertions(+), 166 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index 27a3b12..3fd6ad7 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -67,28 +67,28 @@
 /* Enable debug-checks on stack size - except on x86_64 */
 #if !defined(__x86_64__)
 # ifdef __ia64__
-#  define CDEBUG_STACK() (THREAD_SIZE -				 \
+#  define CDEBUG_STACK() (THREAD_SIZE -					\
 			  ((unsigned long)__builtin_dwarf_cfa() &       \
 			   (THREAD_SIZE - 1)))
 # else
-#  define CDEBUG_STACK() (THREAD_SIZE -				 \
+#  define CDEBUG_STACK() (THREAD_SIZE -					\
 			  ((unsigned long)__builtin_frame_address(0) &  \
 			   (THREAD_SIZE - 1)))
 # endif /* __ia64__ */
 
-#define __CHECK_STACK(msgdata, mask, cdls)			      \
-do {								    \
-	if (unlikely(CDEBUG_STACK() > libcfs_stack)) {		  \
+#define __CHECK_STACK(msgdata, mask, cdls)				\
+do {									\
+	if (unlikely(CDEBUG_STACK() > libcfs_stack)) {			\
 		LIBCFS_DEBUG_MSG_DATA_INIT(msgdata, D_WARNING, NULL);   \
-		libcfs_stack = CDEBUG_STACK();			  \
-		libcfs_debug_msg(msgdata,			       \
-				 "maximum lustre stack %lu\n",	  \
-				 CDEBUG_STACK());		       \
-		(msgdata)->msg_mask = mask;			     \
-		(msgdata)->msg_cdls = cdls;			     \
-		dump_stack();					   \
+		libcfs_stack = CDEBUG_STACK();				\
+		libcfs_debug_msg(msgdata,				\
+				 "maximum lustre stack %lu\n",		\
+				 CDEBUG_STACK());			\
+		(msgdata)->msg_mask = mask;				\
+		(msgdata)->msg_cdls = cdls;				\
+		dump_stack();						\
 	      /*panic("LBUG");*/					\
-	}							       \
+	}								\
 } while (0)
 #define CFS_CHECK_STACK(msgdata, mask, cdls)  __CHECK_STACK(msgdata, mask, cdls)
 #else /* __x86_64__ */
@@ -104,37 +104,37 @@
 #define CDEBUG_DEFAULT_MIN_DELAY ((HZ + 1) / 2) /* jiffies */
 #define CDEBUG_DEFAULT_BACKOFF   2
 struct cfs_debug_limit_state {
-	unsigned long   cdls_next;
-	unsigned int cdls_delay;
-	int	     cdls_count;
+	unsigned long			cdls_next;
+	unsigned int			cdls_delay;
+	int				cdls_count;
 };
 
 struct libcfs_debug_msg_data {
-	const char *msg_file;
-	const char *msg_fn;
-	int	    msg_subsys;
-	int	    msg_line;
-	int	    msg_mask;
-	struct cfs_debug_limit_state *msg_cdls;
+	const char		       *msg_file;
+	const char		       *msg_fn;
+	int				msg_subsys;
+	int				msg_line;
+	int				msg_mask;
+	struct cfs_debug_limit_state   *msg_cdls;
 };
 
-#define LIBCFS_DEBUG_MSG_DATA_INIT(data, mask, cdls)		\
-do {								\
-	(data)->msg_subsys = DEBUG_SUBSYSTEM;			\
-	(data)->msg_file   = __FILE__;				\
-	(data)->msg_fn     = __func__;				\
-	(data)->msg_line   = __LINE__;				\
-	(data)->msg_cdls   = (cdls);				\
-	(data)->msg_mask   = (mask);				\
+#define LIBCFS_DEBUG_MSG_DATA_INIT(data, mask, cdls)			\
+do {									\
+	(data)->msg_subsys = DEBUG_SUBSYSTEM;				\
+	(data)->msg_file   = __FILE__;					\
+	(data)->msg_fn     = __func__;					\
+	(data)->msg_line   = __LINE__;					\
+	(data)->msg_cdls   = (cdls);					\
+	(data)->msg_mask   = (mask);					\
 } while (0)
 
-#define LIBCFS_DEBUG_MSG_DATA_DECL(dataname, mask, cdls)	\
-	static struct libcfs_debug_msg_data dataname = {	\
-	       .msg_subsys = DEBUG_SUBSYSTEM,			\
-	       .msg_file   = __FILE__,				\
-	       .msg_fn     = __func__,				\
-	       .msg_line   = __LINE__,				\
-	       .msg_cdls   = (cdls)	 };			\
+#define LIBCFS_DEBUG_MSG_DATA_DECL(dataname, mask, cdls)		\
+	static struct libcfs_debug_msg_data dataname = {		\
+	       .msg_subsys = DEBUG_SUBSYSTEM,				\
+	       .msg_file   = __FILE__,					\
+	       .msg_fn     = __func__,					\
+	       .msg_line   = __LINE__,					\
+	       .msg_cdls   = (cdls)	 };				\
 	dataname.msg_mask   = (mask)
 
 /**
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index 8074e39..4a41978 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -54,14 +54,14 @@ enum {
 };
 
 /* Failure injection control */
-#define CFS_FAIL_MASK_SYS    0x0000FF00
-#define CFS_FAIL_MASK_LOC   (0x000000FF | CFS_FAIL_MASK_SYS)
+#define CFS_FAIL_MASK_SYS	0x0000FF00
+#define CFS_FAIL_MASK_LOC	(0x000000FF | CFS_FAIL_MASK_SYS)
 
-#define CFS_FAILED_BIT       30
+#define CFS_FAILED_BIT		30
 /* CFS_FAILED is 0x40000000 */
 #define CFS_FAILED		BIT(CFS_FAILED_BIT)
 
-#define CFS_FAIL_ONCE_BIT    31
+#define CFS_FAIL_ONCE_BIT	31
 /* CFS_FAIL_ONCE is 0x80000000 */
 #define CFS_FAIL_ONCE		BIT(CFS_FAIL_ONCE_BIT)
 
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 491d597..d525e4f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -69,9 +69,9 @@
 
 void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msg);
 
-#define LBUG()							  \
-do {								    \
-	LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, D_EMERG, NULL);	     \
+#define LBUG()								\
+do {									\
+	LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, D_EMERG, NULL);		\
 	lbug_with_loc(&msgdata);					\
 } while (0)
 
@@ -86,7 +86,7 @@
 	kmalloc_node(size, flags | __GFP_ZERO,				\
 		     cfs_cpt_spread_node(lnet_cpt_table(), cpt))
 
-#define kvmalloc_cpt(size, flags, cpt) \
+#define kvmalloc_cpt(size, flags, cpt)					\
 	kvmalloc_node(size, flags,					\
 		      cfs_cpt_spread_node(lnet_cpt_table(), cpt))
 
@@ -138,50 +138,50 @@
 	LASSERTF(atomic_read(a) >= v, "value: %d\n", atomic_read((a)))
 
 /** assert value of @a is great than @v1 and little than @v2 */
-#define LASSERT_ATOMIC_GT_LT(a, v1, v2)			 \
-do {							    \
-	int __v = atomic_read(a);			   \
+#define LASSERT_ATOMIC_GT_LT(a, v1, v2)				\
+do {								\
+	int __v = atomic_read(a);				\
 	LASSERTF(__v > v1 && __v < v2, "value: %d\n", __v);     \
 } while (0)
 
 /** assert value of @a is great than @v1 and little/equal to @v2 */
-#define LASSERT_ATOMIC_GT_LE(a, v1, v2)			 \
-do {							    \
-	int __v = atomic_read(a);			   \
+#define LASSERT_ATOMIC_GT_LE(a, v1, v2)				\
+do {								\
+	int __v = atomic_read(a);				\
 	LASSERTF(__v > v1 && __v <= v2, "value: %d\n", __v);    \
 } while (0)
 
 /** assert value of @a is great/equal to @v1 and little than @v2 */
-#define LASSERT_ATOMIC_GE_LT(a, v1, v2)			 \
-do {							    \
-	int __v = atomic_read(a);			   \
+#define LASSERT_ATOMIC_GE_LT(a, v1, v2)				\
+do {								\
+	int __v = atomic_read(a);				\
 	LASSERTF(__v >= v1 && __v < v2, "value: %d\n", __v);    \
 } while (0)
 
 /** assert value of @a is great/equal to @v1 and little/equal to @v2 */
-#define LASSERT_ATOMIC_GE_LE(a, v1, v2)			 \
-do {							    \
-	int __v = atomic_read(a);			   \
+#define LASSERT_ATOMIC_GE_LE(a, v1, v2)				\
+do {								\
+	int __v = atomic_read(a);				\
 	LASSERTF(__v >= v1 && __v <= v2, "value: %d\n", __v);   \
 } while (0)
 
 #else /* !LASSERT_ATOMIC_ENABLED */
 
-#define LASSERT_ATOMIC_EQ(a, v)		 do {} while (0)
-#define LASSERT_ATOMIC_NE(a, v)		 do {} while (0)
-#define LASSERT_ATOMIC_LT(a, v)		 do {} while (0)
-#define LASSERT_ATOMIC_LE(a, v)		 do {} while (0)
-#define LASSERT_ATOMIC_GT(a, v)		 do {} while (0)
-#define LASSERT_ATOMIC_GE(a, v)		 do {} while (0)
-#define LASSERT_ATOMIC_GT_LT(a, v1, v2)	 do {} while (0)
-#define LASSERT_ATOMIC_GT_LE(a, v1, v2)	 do {} while (0)
-#define LASSERT_ATOMIC_GE_LT(a, v1, v2)	 do {} while (0)
-#define LASSERT_ATOMIC_GE_LE(a, v1, v2)	 do {} while (0)
+#define LASSERT_ATOMIC_EQ(a, v)		do {} while (0)
+#define LASSERT_ATOMIC_NE(a, v)		do {} while (0)
+#define LASSERT_ATOMIC_LT(a, v)		do {} while (0)
+#define LASSERT_ATOMIC_LE(a, v)		do {} while (0)
+#define LASSERT_ATOMIC_GT(a, v)		do {} while (0)
+#define LASSERT_ATOMIC_GE(a, v)		do {} while (0)
+#define LASSERT_ATOMIC_GT_LT(a, v1, v2)	do {} while (0)
+#define LASSERT_ATOMIC_GT_LE(a, v1, v2)	do {} while (0)
+#define LASSERT_ATOMIC_GE_LT(a, v1, v2)	do {} while (0)
+#define LASSERT_ATOMIC_GE_LE(a, v1, v2)	do {} while (0)
 
 #endif /* LASSERT_ATOMIC_ENABLED */
 
-#define LASSERT_ATOMIC_ZERO(a)		  LASSERT_ATOMIC_EQ(a, 0)
-#define LASSERT_ATOMIC_POS(a)		   LASSERT_ATOMIC_GT(a, 0)
+#define LASSERT_ATOMIC_ZERO(a)		LASSERT_ATOMIC_EQ(a, 0)
+#define LASSERT_ATOMIC_POS(a)		LASSERT_ATOMIC_GT(a, 0)
 
 /* implication */
 #define ergo(a, b) (!(a) || (b))
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index 3117708..f2ac9dc 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -53,8 +53,8 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
  * Structure to represent NULL-less strings.
  */
 struct cfs_lstr {
-	char		*ls_str;
-	int		ls_len;
+	char			*ls_str;
+	int			ls_len;
 };
 
 /*
@@ -65,9 +65,9 @@ struct cfs_range_expr {
 	 * Link to cfs_expr_list::el_exprs.
 	 */
 	struct list_head	re_link;
-	u32		re_lo;
-	u32		re_hi;
-	u32		re_stride;
+	u32			re_lo;
+	u32			re_hi;
+	u32			re_stride;
 };
 
 struct cfs_expr_list {
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index f954436..b7f0c73 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -85,8 +85,8 @@ static int libcfs_param_debug_mb_set(const char *val,
  * debug_mb parameter type with corresponding methods to handle this case
  */
 static const struct kernel_param_ops param_ops_debug_mb = {
-	.set = libcfs_param_debug_mb_set,
-	.get = param_get_uint,
+	.set		= libcfs_param_debug_mb_set,
+	.get		= param_get_uint,
 };
 
 #define param_check_debug_mb(name, p) \
@@ -143,8 +143,8 @@ static int param_set_console_max_delay(const char *val,
 }
 
 static const struct kernel_param_ops param_ops_console_max_delay = {
-	.set = param_set_console_max_delay,
-	.get = param_get_delay,
+	.set		= param_set_console_max_delay,
+	.get		= param_get_delay,
 };
 
 #define param_check_console_max_delay(name, p) \
@@ -161,8 +161,8 @@ static int param_set_console_min_delay(const char *val,
 }
 
 static const struct kernel_param_ops param_ops_console_min_delay = {
-	.set = param_set_console_min_delay,
-	.get = param_get_delay,
+	.set		= param_set_console_min_delay,
+	.get		= param_get_delay,
 };
 
 #define param_check_console_min_delay(name, p) \
@@ -195,8 +195,8 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 }
 
 static const struct kernel_param_ops param_ops_uintpos = {
-	.set = param_set_uintpos,
-	.get = param_get_uint,
+	.set		= param_set_uintpos,
+	.get		= param_get_uint,
 };
 
 #define param_check_uintpos(name, p) \
@@ -499,9 +499,9 @@ static int panic_notifier(struct notifier_block *self, unsigned long unused1,
 }
 
 static struct notifier_block libcfs_panic_notifier = {
-	.notifier_call	= panic_notifier,
-	.next		= NULL,
-	.priority	= 10000,
+	.notifier_call		= panic_notifier,
+	.next			= NULL,
+	.priority		= 10000,
 };
 
 static void libcfs_register_panic_notifier(void)
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index a384a73..262469f 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -76,7 +76,7 @@ struct cfs_cpt_table {
 };
 
 /** Global CPU partition table */
-struct cfs_cpt_table   *cfs_cpt_tab __read_mostly;
+struct cfs_cpt_table *cfs_cpt_tab __read_mostly;
 EXPORT_SYMBOL(cfs_cpt_tab);
 
 /**
@@ -86,7 +86,7 @@ struct cfs_cpt_table {
  *  1 : disable multiple partitions
  * >1 : specify number of partitions
  */
-static int	cpu_npartitions;
+static int cpu_npartitions;
 module_param(cpu_npartitions, int, 0444);
 MODULE_PARM_DESC(cpu_npartitions, "# of CPU partitions");
 
@@ -103,7 +103,7 @@ struct cfs_cpt_table {
  *
  * NB: If user specified cpu_pattern, cpu_npartitions will be ignored
  */
-static char	*cpu_pattern = "N";
+static char *cpu_pattern = "N";
 module_param(cpu_pattern, charp, 0444);
 MODULE_PARM_DESC(cpu_pattern, "CPU partitions pattern");
 
@@ -167,7 +167,7 @@ struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt)
 						    GFP_KERNEL);
 		if (!part->cpt_distance) {
 			kfree(part->cpt_nodemask);
-		failed_setting_one_part:
+failed_setting_one_part:
 			free_cpumask_var(part->cpt_cpumask);
 			goto failed_setting_ctb_parts;
 		}
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index e1fb126..5fb8524 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -314,11 +314,11 @@ char *cfs_firststr(char *str, size_t size)
 		}
 	}
 
- out:
+out:
 	*expr = re;
 	return 0;
 
- failed:
+failed:
 	kfree(re);
 	return -EINVAL;
 }
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c b/drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c
index db81ed52..d3da7a22 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c
@@ -104,7 +104,7 @@ static int adler32_digest(struct shash_desc *desc, const u8 *data,
 			  unsigned int len, u8 *out)
 {
 	return __adler32_finup(crypto_shash_ctx(desc->tfm), data, len,
-				    out);
+			       out);
 }
 
 static struct shash_alg alg = {
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
index b206e3c..a0b1377 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
@@ -205,7 +205,6 @@ struct ahash_request *
 	const struct cfs_crypto_hash_type *type;
 
 	err = cfs_crypto_hash_alloc(hash_alg, &type, &req, key, key_len);
-
 	if (err)
 		return ERR_PTR(err);
 	return req;
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 1de83b1..dd9a953 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -60,8 +60,8 @@
 #include "tracefile.h"
 
 struct lnet_debugfs_symlink_def {
-	const char *name;
-	const char *target;
+	const char	*name;
+	const char	*target;
 };
 
 static struct dentry *lnet_debugfs_root;
@@ -281,14 +281,14 @@ static int libcfs_ioctl(unsigned long cmd, void __user *uparam)
 }
 
 static const struct file_operations libcfs_fops = {
-	.owner		= THIS_MODULE,
-	.unlocked_ioctl	= libcfs_psdev_ioctl,
+	.owner			= THIS_MODULE,
+	.unlocked_ioctl		= libcfs_psdev_ioctl,
 };
 
 static struct miscdevice libcfs_dev = {
-	.minor = MISC_DYNAMIC_MINOR,
-	.name = "lnet",
-	.fops = &libcfs_fops,
+	.minor			= MISC_DYNAMIC_MINOR,
+	.name			= "lnet",
+	.fops			= &libcfs_fops,
 };
 
 static int libcfs_dev_registered;
@@ -423,7 +423,7 @@ static int proc_cpt_table(struct ctl_table *table, int write,
 	}
 
 	rc = cfs_trace_copyout_string(buffer, nob, buf + pos, NULL);
- out:
+out:
 	kfree(buf);
 	return rc;
 }
@@ -472,84 +472,84 @@ static int proc_cpt_distance(struct ctl_table *table, int write,
 
 static struct ctl_table lnet_table[] = {
 	{
-		.procname = "debug",
-		.data     = &libcfs_debug,
-		.maxlen   = sizeof(int),
-		.mode     = 0644,
-		.proc_handler = &proc_dobitmasks,
+		.procname	= "debug",
+		.data		= &libcfs_debug,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dobitmasks,
 	},
 	{
-		.procname = "subsystem_debug",
-		.data     = &libcfs_subsystem_debug,
-		.maxlen   = sizeof(int),
-		.mode     = 0644,
-		.proc_handler = &proc_dobitmasks,
+		.procname	= "subsystem_debug",
+		.data		= &libcfs_subsystem_debug,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dobitmasks,
 	},
 	{
-		.procname = "printk",
-		.data     = &libcfs_printk,
-		.maxlen   = sizeof(int),
-		.mode     = 0644,
-		.proc_handler = &proc_dobitmasks,
+		.procname	= "printk",
+		.data		= &libcfs_printk,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dobitmasks,
 	},
 	{
-		.procname = "cpu_partition_table",
-		.maxlen   = 128,
-		.mode     = 0444,
-		.proc_handler = &proc_cpt_table,
+		.procname	= "cpu_partition_table",
+		.maxlen		= 128,
+		.mode		= 0444,
+		.proc_handler	= &proc_cpt_table,
 	},
 	{
-		.procname = "cpu_partition_distance",
-		.maxlen	  = 128,
-		.mode	  = 0444,
-		.proc_handler = &proc_cpt_distance,
+		.procname	= "cpu_partition_distance",
+		.maxlen		= 128,
+		.mode		= 0444,
+		.proc_handler	= &proc_cpt_distance,
 	},
 	{
-		.procname = "debug_log_upcall",
-		.data     = lnet_debug_log_upcall,
-		.maxlen   = sizeof(lnet_debug_log_upcall),
-		.mode     = 0644,
-		.proc_handler = &proc_dostring,
+		.procname	= "debug_log_upcall",
+		.data		= lnet_debug_log_upcall,
+		.maxlen		= sizeof(lnet_debug_log_upcall),
+		.mode		= 0644,
+		.proc_handler	= &proc_dostring,
 	},
 	{
-		.procname = "catastrophe",
-		.data     = &libcfs_catastrophe,
-		.maxlen   = sizeof(int),
-		.mode     = 0444,
-		.proc_handler = &proc_dointvec,
+		.procname	= "catastrophe",
+		.data		= &libcfs_catastrophe,
+		.maxlen		= sizeof(int),
+		.mode		= 0444,
+		.proc_handler	= &proc_dointvec,
 	},
 	{
-		.procname = "dump_kernel",
-		.maxlen   = 256,
-		.mode     = 0200,
-		.proc_handler = &proc_dump_kernel,
+		.procname	= "dump_kernel",
+		.maxlen		= 256,
+		.mode		= 0200,
+		.proc_handler	= &proc_dump_kernel,
 	},
 	{
-		.procname = "daemon_file",
-		.mode     = 0644,
-		.maxlen   = 256,
-		.proc_handler = &proc_daemon_file,
+		.procname	= "daemon_file",
+		.mode		= 0644,
+		.maxlen		= 256,
+		.proc_handler	= &proc_daemon_file,
 	},
 	{
-		.procname = "force_lbug",
-		.data     = NULL,
-		.maxlen   = 0,
-		.mode     = 0200,
-		.proc_handler = &libcfs_force_lbug
+		.procname	= "force_lbug",
+		.data		= NULL,
+		.maxlen		= 0,
+		.mode		= 0200,
+		.proc_handler	= &libcfs_force_lbug
 	},
 	{
-		.procname = "fail_loc",
-		.data     = &cfs_fail_loc,
-		.maxlen   = sizeof(cfs_fail_loc),
-		.mode     = 0644,
-		.proc_handler = &proc_fail_loc
+		.procname	= "fail_loc",
+		.data		= &cfs_fail_loc,
+		.maxlen		= sizeof(cfs_fail_loc),
+		.mode		= 0644,
+		.proc_handler	= &proc_fail_loc
 	},
 	{
-		.procname = "fail_val",
-		.data     = &cfs_fail_val,
-		.maxlen   = sizeof(int),
-		.mode     = 0644,
-		.proc_handler = &proc_dointvec
+		.procname	= "fail_val",
+		.data		= &cfs_fail_val,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
 	},
 	{
 		.procname	= "fail_err",
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 22b1dd0..40440ce 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -331,7 +331,6 @@ static struct cfs_trace_page *cfs_trace_get_tage(struct cfs_trace_cpu_data *tcd,
 	 * XXX nikita: do NOT call portals_debug_msg() (CDEBUG/ENTRY/EXIT)
 	 * from here: this will lead to infinite recursion.
 	 */
-
 	if (len > PAGE_SIZE) {
 		pr_err("cowardly refusing to write %lu bytes in a page\n", len);
 		return NULL;
@@ -489,7 +488,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 		}
 
 		string_buf = (char *)page_address(tage->page) +
-					tage->used + known_size;
+			     tage->used + known_size;
 
 		max_nob = PAGE_SIZE - tage->used - known_size;
 		if (max_nob <= 0) {
@@ -746,7 +745,7 @@ static void put_pages_back(struct page_collection *pc)
 		put_pages_back_on_all_cpus(pc);
 }
 
-/* Add pages to a per-cpu debug daemon ringbuffer.  This buffer makes sure that
+/* Add pages to a per-cpu debug daemon ringbuffer. This buffer makes sure that
  * we have a good amount of data@all times for dumping during an LBUG, even
  * if we have been steadily writing (and otherwise discarding) pages via the
  * debug daemon.
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index 2134549..71a031d1 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -165,12 +165,12 @@ void cfs_trace_assertion_failed(const char *str,
 	}								\
 } while (0)
 
-#define __LASSERT_TAGE_INVARIANT(tage)			\
-do {							\
-	__LASSERT(tage);				\
-	__LASSERT(tage->page);				\
-	__LASSERT(tage->used <= PAGE_SIZE);		\
-	__LASSERT(page_count(tage->page) > 0);		\
+#define __LASSERT_TAGE_INVARIANT(tage)					\
+do {									\
+	__LASSERT(tage);						\
+	__LASSERT(tage->page);						\
+	__LASSERT(tage->used <= PAGE_SIZE);				\
+	__LASSERT(page_count(tage->page) > 0);				\
 } while (0)
 
 #endif /* __LIBCFS_TRACEFILE_H__ */
-- 
1.8.3.1
