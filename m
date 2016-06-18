From: Craig Inches <craig@craiginches.com>
Date: Sat, 18 Jun 2016 22:25:42 +0100
Subject: [lustre-devel] [PATCH 1/3] staging: luster: cl_object.h Checkpatch
	Cleanup
In-Reply-To: <cover.1466279901.git.craig@craiginches.com>
References: <cover.1466279901.git.craig@craiginches.com>
Message-ID: <4b26b82c7081f368835365ff18ecc812263b0430.1466279901.git.craig@craiginches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Line length greater than 80 char.

Signed-off-by: Craig Inches <craig@craiginches.com>

---
 drivers/staging/lustre/lustre/include/cl_object.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 99fc28e..3004625 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1054,7 +1054,7 @@ do {								    \
 #define CL_PAGE_HEADER(mask, env, page, format, ...)			  \
 do {									  \
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			 \
-		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		cl_page_header_print(env, &msgdata, lu_cdebug_printer, page); \
 		CDEBUG(mask, format, ## __VA_ARGS__);			\
 	}								     \
-- 
2.7.3
