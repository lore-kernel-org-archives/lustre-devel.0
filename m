From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:12 -0500
Subject: [lustre-devel] [PATCH 204/622] lnet: libcfs: allow file/func/line
 passed to CDEBUG()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-205-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Allow the file, function, and line number to be passed to CDEBUG()
messages so that they are not duplicated in helper functions that
may be called from multiple places.

This patch is largely a no-op in terms of code, with the exception
of one call in osc_extent_sanity_check0() to OSC_EXTENT_DUMP() that
is changed to OSC_EXTENT_DUMP_WITH_LOC().

WC-bug-id: https://jira.whamcloud.com/browse/LU-4664
Lustre-commit: 8503e73bd936 ("LU-4664 libcfs: allow file/func/line passed to CDEBUG()")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33588
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c           | 43 +++++++++++++----------
 include/linux/libcfs/libcfs_debug.h | 69 ++++++++++++++++++++++---------------
 2 files changed, 65 insertions(+), 47 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 1ff258c..a18e791 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -58,10 +58,10 @@ static int osc_io_unplug_async(const struct lu_env *env,
 static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 			   unsigned int lost_grant, unsigned int dirty_grant);
 
-static void __osc_extent_tree_dump(int level, struct osc_object *obj,
+static void __osc_extent_tree_dump(int mask, struct osc_object *obj,
 				   const char *func, int line);
-#define osc_extent_tree_dump(lvl, obj) \
-	__osc_extent_tree_dump(lvl, obj, __func__, __LINE__)
+#define osc_extent_tree_dump(mask, obj) \
+	__osc_extent_tree_dump(mask, obj, __func__, __LINE__)
 
 static void osc_unreserve_grant(struct client_obd *cli, unsigned int reserved,
 				unsigned int unused);
@@ -106,18 +106,19 @@ static inline char list_empty_marker(struct list_head *list)
 static const char * const oes_strings[] = {
 	"inv", "active", "cache", "locking", "lockdone", "rpc", "trunc", NULL };
 
-#define OSC_EXTENT_DUMP(lvl, extent, fmt, ...) do {			      \
+#define OSC_EXTENT_DUMP_WITH_LOC(file, func, line, mask, extent, fmt, ...) do {\
+	static struct cfs_debug_limit_state cdls;			      \
 	struct osc_extent *__ext = (extent);				      \
 	char __buf[16];							      \
 									      \
-	CDEBUG(lvl,							      \
+	__CDEBUG_WITH_LOC(file, func, line, mask, &cdls,		      \
 		"extent %p@{" EXTSTR ", "				      \
 		"[%d|%d|%c|%s|%s|%p], [%d|%d|%c|%c|%p|%u|%p]} " fmt,	      \
 		/* ----- extent part 0 ----- */				      \
 		__ext, EXTPARA(__ext),					      \
 		/* ----- part 1 ----- */				      \
 		kref_read(&__ext->oe_refc),				      \
-		atomic_read(&__ext->oe_users),			      \
+		atomic_read(&__ext->oe_users),				      \
 		list_empty_marker(&__ext->oe_link),			      \
 		oes_strings[__ext->oe_state], ext_flags(__ext, __buf),	      \
 		__ext->oe_obj,						      \
@@ -128,12 +129,16 @@ static inline char list_empty_marker(struct list_head *list)
 		__ext->oe_dlmlock, __ext->oe_mppr, __ext->oe_owner,	      \
 		/* ----- part 4 ----- */				      \
 		## __VA_ARGS__);					      \
-	if (lvl == D_ERROR && __ext->oe_dlmlock)			      \
+	if (mask == D_ERROR && __ext->oe_dlmlock)			      \
 		LDLM_ERROR(__ext->oe_dlmlock, "extent: %p", __ext);	      \
 	else								      \
 		LDLM_DEBUG(__ext->oe_dlmlock, "extent: %p", __ext);	      \
 } while (0)
 
+#define OSC_EXTENT_DUMP(mask, ext, fmt, ...)				\
+	OSC_EXTENT_DUMP_WITH_LOC(__FILE__, __func__, __LINE__,		\
+				 mask, ext, fmt, ## __VA_ARGS__)
+
 #undef EASSERTF
 #define EASSERTF(expr, ext, fmt, args...) do {				\
 	if (!(expr)) {							\
@@ -300,9 +305,9 @@ static int __osc_extent_sanity_check(struct osc_extent *ext,
 
 out:
 	if (rc != 0)
-		OSC_EXTENT_DUMP(D_ERROR, ext,
-				"%s:%d sanity check %p failed with rc = %d\n",
-				func, line, ext, rc);
+		OSC_EXTENT_DUMP_WITH_LOC(__FILE__, func, line, D_ERROR, ext,
+					 "sanity check %p failed: rc = %d\n",
+					 ext, rc);
 	return rc;
 }
 
@@ -1250,34 +1255,34 @@ static int osc_extent_expand(struct osc_extent *ext, pgoff_t index,
 	return rc;
 }
 
-static void __osc_extent_tree_dump(int level, struct osc_object *obj,
+static void __osc_extent_tree_dump(int mask, struct osc_object *obj,
 				   const char *func, int line)
 {
 	struct osc_extent *ext;
 	int cnt;
 
-	if (!cfs_cdebug_show(level, DEBUG_SUBSYSTEM))
+	if (!cfs_cdebug_show(mask, DEBUG_SUBSYSTEM))
 		return;
 
-	CDEBUG(level, "Dump object %p extents at %s:%d, mppr: %u.\n",
+	CDEBUG(mask, "Dump object %p extents at %s:%d, mppr: %u.\n",
 	       obj, func, line, osc_cli(obj)->cl_max_pages_per_rpc);
 
 	/* osc_object_lock(obj); */
 	cnt = 1;
 	for (ext = first_extent(obj); ext; ext = next_extent(ext))
-		OSC_EXTENT_DUMP(level, ext, "in tree %d.\n", cnt++);
+		OSC_EXTENT_DUMP(mask, ext, "in tree %d.\n", cnt++);
 
 	cnt = 1;
 	list_for_each_entry(ext, &obj->oo_hp_exts, oe_link)
-		OSC_EXTENT_DUMP(level, ext, "hp %d.\n", cnt++);
+		OSC_EXTENT_DUMP(mask, ext, "hp %d.\n", cnt++);
 
 	cnt = 1;
 	list_for_each_entry(ext, &obj->oo_urgent_exts, oe_link)
-		OSC_EXTENT_DUMP(level, ext, "urgent %d.\n", cnt++);
+		OSC_EXTENT_DUMP(mask, ext, "urgent %d.\n", cnt++);
 
 	cnt = 1;
 	list_for_each_entry(ext, &obj->oo_reading_exts, oe_link)
-		OSC_EXTENT_DUMP(level, ext, "reading %d.\n", cnt++);
+		OSC_EXTENT_DUMP(mask, ext, "reading %d.\n", cnt++);
 	/* osc_object_unlock(obj); */
 }
 
@@ -1395,9 +1400,9 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	return 0;
 }
 
-#define OSC_DUMP_GRANT(lvl, cli, fmt, args...) do {			\
+#define OSC_DUMP_GRANT(mask, cli, fmt, args...) do {			\
 	struct client_obd *__tmp = (cli);				\
-	CDEBUG(lvl, "%s: grant { dirty: %ld/%ld dirty_pages: %ld/%lu "	\
+	CDEBUG(mask, "%s: grant { dirty: %ld/%ld dirty_pages: %ld/%lu "	\
 	       "dropped: %ld avail: %ld, dirty_grant: %ld, "		\
 	       "reserved: %ld, flight: %d } lru {in list: %ld, "	\
 	       "left: %ld, waiters: %d }" fmt "\n",			\
diff --git a/include/linux/libcfs/libcfs_debug.h b/include/linux/libcfs/libcfs_debug.h
index 31a97ec..99905f7 100644
--- a/include/linux/libcfs/libcfs_debug.h
+++ b/include/linux/libcfs/libcfs_debug.h
@@ -79,26 +79,29 @@
 			   (THREAD_SIZE - 1)))
 # endif /* __ia64__ */
 
-#define __CHECK_STACK(msgdata, mask, cdls)				\
+#define __CHECK_STACK_WITH_LOC(file, func, line, msgdata, mask, cdls)	\
 do {									\
 	if (unlikely(CDEBUG_STACK() > libcfs_stack)) {			\
-		LIBCFS_DEBUG_MSG_DATA_INIT(msgdata, D_WARNING, NULL);   \
+		LIBCFS_DEBUG_MSG_DATA_INIT(file, func, line, msgdata,	\
+					   D_WARNING, NULL);		\
 		libcfs_stack = CDEBUG_STACK();				\
-		libcfs_debug_msg(msgdata,				\
-				 "maximum lustre stack %lu\n",		\
-				 CDEBUG_STACK());			\
+		libcfs_debug_msg(msgdata, "maximum lustre stack %u\n",	\
+				 libcfs_stack);				\
 		(msgdata)->msg_mask = mask;				\
 		(msgdata)->msg_cdls = cdls;				\
 		dump_stack();						\
 		/*panic("LBUG");*/					\
 	}								\
 } while (0)
-#define CFS_CHECK_STACK(msgdata, mask, cdls)  __CHECK_STACK(msgdata, mask, cdls)
 #else /* __x86_64__ */
-#define CFS_CHECK_STACK(msgdata, mask, cdls) do {} while (0)
 #define CDEBUG_STACK() (0L)
+#define __CHECK_STACK_WITH_LOC(file, func, line, msgdata, mask, cdls)	\
+	do {} while (0)
 #endif /* __x86_64__ */
 
+#define CFS_CHECK_STACK(msgdata, mask, cdls)				\
+	__CHECK_STACK_WITH_LOC(__FILE__, __func__, __LINE__,		\
+			       msgdata, mask, cdls)
 #ifndef DEBUG_SUBSYSTEM
 # define DEBUG_SUBSYSTEM S_UNDEFINED
 #endif
@@ -121,24 +124,28 @@ struct libcfs_debug_msg_data {
 	struct cfs_debug_limit_state   *msg_cdls;
 };
 
-#define LIBCFS_DEBUG_MSG_DATA_INIT(data, mask, cdls)			\
+#define LIBCFS_DEBUG_MSG_DATA_INIT(file, func, line, msgdata, mask, cdls)\
 do {									\
-	(data)->msg_subsys	= DEBUG_SUBSYSTEM;			\
-	(data)->msg_file	= __FILE__;				\
-	(data)->msg_fn		= __func__;				\
-	(data)->msg_line	= __LINE__;				\
-	(data)->msg_cdls	= (cdls);				\
-	(data)->msg_mask	= (mask);				\
+	(msgdata)->msg_subsys = DEBUG_SUBSYSTEM;			\
+	(msgdata)->msg_file   = (file);					\
+	(msgdata)->msg_fn     = (func);					\
+	(msgdata)->msg_line   = (line);					\
+	(msgdata)->msg_mask   = (mask);					\
+	(msgdata)->msg_cdls   = (cdls);					\
 } while (0)
 
-#define LIBCFS_DEBUG_MSG_DATA_DECL(dataname, mask, cdls)		\
-	static struct libcfs_debug_msg_data dataname = {		\
-		.msg_subsys	= DEBUG_SUBSYSTEM,			\
-		.msg_file	= __FILE__,				\
-		.msg_fn		= __func__,				\
-		.msg_line	= __LINE__,				\
-		.msg_cdls	= (cdls)	 };			\
-	dataname.msg_mask	= (mask)
+#define LIBCFS_DEBUG_MSG_DATA_DECL_LOC(file, func, line, msgdata, mask, cdls)\
+	static struct libcfs_debug_msg_data msgdata = {			\
+		.msg_subsys = DEBUG_SUBSYSTEM,				\
+		.msg_file   = (file),					\
+		.msg_fn     = (func),					\
+		.msg_line   = (line),					\
+		.msg_cdls   = (cdls) };					\
+	msgdata.msg_mask   = (mask)
+
+#define LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, cdls)			\
+	LIBCFS_DEBUG_MSG_DATA_DECL_LOC(__FILE__, __func__, __LINE__,	\
+				       msgdata, mask, cdls)
 
 /**
  * Filters out logging messages based on mask and subsystem.
@@ -147,27 +154,32 @@ static inline int cfs_cdebug_show(unsigned int mask, unsigned int subsystem)
 {
 	return mask & D_CANTMASK ||
 		((libcfs_debug & mask) && (libcfs_subsystem_debug & subsystem));
+
 }
 
-#define __CDEBUG(cdls, mask, format, ...)				\
+#define __CDEBUG_WITH_LOC(file, func, line, mask, cdls, format, ...)	\
 do {									\
 	static struct libcfs_debug_msg_data msgdata;			\
 									\
-	CFS_CHECK_STACK(&msgdata, mask, cdls);				\
+	__CHECK_STACK_WITH_LOC(file, func, line, &msgdata, mask, cdls);	\
 									\
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			\
-		LIBCFS_DEBUG_MSG_DATA_INIT(&msgdata, mask, cdls);	\
+		LIBCFS_DEBUG_MSG_DATA_INIT(file, func, line,		\
+					   &msgdata, mask, cdls);	\
 		libcfs_debug_msg(&msgdata, format, ## __VA_ARGS__);	\
 	}								\
 } while (0)
 
-#define CDEBUG(mask, format, ...) __CDEBUG(NULL, mask, format, ## __VA_ARGS__)
+#define CDEBUG(mask, format, ...)					\
+	__CDEBUG_WITH_LOC(__FILE__, __func__, __LINE__,			\
+			  mask, NULL, format, ## __VA_ARGS__)
 
 #define CDEBUG_LIMIT(mask, format, ...)					\
 do {									\
 	static struct cfs_debug_limit_state cdls;			\
 									\
-	__CDEBUG(&cdls, mask, format, ## __VA_ARGS__);			\
+	__CDEBUG_WITH_LOC(__FILE__, __func__, __LINE__,			\
+			  mask, &cdls, format, ## __VA_ARGS__);		\
 } while (0)
 
 /*
@@ -189,7 +201,8 @@ static inline int cfs_cdebug_show(unsigned int mask, unsigned int subsystem)
 			   "%x-%x: " format, errnum, LERRCHKSUM(errnum), ## __VA_ARGS__)
 #define LCONSOLE_ERROR(format, ...) LCONSOLE_ERROR_MSG(0x00, format, ## __VA_ARGS__)
 
-#define LCONSOLE_EMERG(format, ...) CDEBUG(D_CONSOLE | D_EMERG, format, ## __VA_ARGS__)
+#define LCONSOLE_EMERG(format, ...) \
+	CDEBUG(D_CONSOLE | D_EMERG, format, ## __VA_ARGS__)
 
 int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 		     const char *format1, ...)
-- 
1.8.3.1
