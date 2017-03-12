From: Craig Inches <Craig@craiginches.com>
Date: Sun, 12 Mar 2017 19:18:40 +0000
Subject: [lustre-devel] [PATCH] staging: lustre shorten multiple lines over
	80 char in lu_object.h
Message-ID: <20170312191840.20981-1-Craig@craiginches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Craig Inches <Craig@craiginches.com>

This patch adjusts lines so that they are less than 80 char.
Checkpatch.pl idenitified the issue.

Signed-off-by: Craig Inches <Craig@craiginches.com>
---
 drivers/staging/lustre/lustre/include/lu_object.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 7a4f412..73ecc23 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -147,9 +147,9 @@ struct lu_device_operations {
 				     struct lu_device *);
 
 	/**
-	 * initialize local objects for device. this method called after layer has
-	 * been initialized (after LCFG_SETUP stage) and before it starts serving
-	 * user requests.
+	 * initialize local objects for device. this method called after layer
+	 * has been initialized (after LCFG_SETUP stage) and before it starts
+	 * serving user requests.
 	 */
 
 	int (*ldo_prepare)(const struct lu_env *,
@@ -791,7 +791,7 @@ int lu_cdebug_printer(const struct lu_env *env,
 #define LU_OBJECT_DEBUG(mask, env, object, format, ...)		   \
 do {								      \
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {		     \
-		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		lu_object_print(env, &msgdata, lu_cdebug_printer, object);\
 		CDEBUG(mask, format "\n", ## __VA_ARGS__);		    \
 	}								 \
@@ -803,7 +803,7 @@ do {								      \
 #define LU_OBJECT_HEADER(mask, env, object, format, ...)		\
 do {								    \
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {		   \
-		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		lu_object_header_print(env, &msgdata, lu_cdebug_printer,\
 				       (object)->lo_header);	    \
 		lu_cdebug_printer(env, &msgdata, "\n");		 \
-- 
2.10.2
