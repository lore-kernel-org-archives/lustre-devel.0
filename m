From: James Simmons <jsimmons@infradead.org>
Date: Thu, 28 Apr 2016 12:07:31 -0400
Subject: [lustre-devel] [PATCH 1/8] staging: lustre: debug: initialize
	debug_msg_data if needed
In-Reply-To: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
References: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461859658-22200-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>, James Simmons <jsimmons@infradead.org>

From: Oleg Drokin <green@linuxhacker.ru>

initialize the libcfs_debug_msg_data only if needed

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1408
Reviewed-on: http://review.whamcloud.com/8338
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h | 6 ++----
 drivers/staging/lustre/lustre/include/lu_object.h | 6 ++----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 587a236..d4c33dd 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1041,9 +1041,8 @@ struct cl_page_operations {
  */
 #define CL_PAGE_DEBUG(mask, env, page, format, ...)		     \
 do {								    \
-	LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
-									\
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {		   \
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		cl_page_print(env, &msgdata, lu_cdebug_printer, page);  \
 		CDEBUG(mask, format, ## __VA_ARGS__);		  \
 	}							       \
@@ -1054,9 +1053,8 @@ do {								    \
  */
 #define CL_PAGE_HEADER(mask, env, page, format, ...)			  \
 do {									  \
-	LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		      \
-									      \
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			 \
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
 		cl_page_header_print(env, &msgdata, lu_cdebug_printer, page); \
 		CDEBUG(mask, format, ## __VA_ARGS__);			\
 	}								     \
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index dad757f..41c45ff 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -781,9 +781,8 @@ int lu_cdebug_printer(const struct lu_env *env,
  */
 #define LU_OBJECT_DEBUG(mask, env, object, format, ...)		   \
 do {								      \
-	LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		  \
-									  \
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {		     \
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
 		lu_object_print(env, &msgdata, lu_cdebug_printer, object);\
 		CDEBUG(mask, format, ## __VA_ARGS__);		    \
 	}								 \
@@ -794,9 +793,8 @@ do {								      \
  */
 #define LU_OBJECT_HEADER(mask, env, object, format, ...)		\
 do {								    \
-	LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
-									\
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {		   \
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
 		lu_object_header_print(env, &msgdata, lu_cdebug_printer,\
 				       (object)->lo_header);	    \
 		lu_cdebug_printer(env, &msgdata, "\n");		 \
-- 
2.7.4
