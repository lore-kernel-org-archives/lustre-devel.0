From: Craig Inches <craig@craiginches.com>
Date: Sat, 18 Jun 2016 22:25:55 +0100
Subject: [lustre-devel] [PATCH 2/3] staging: luster: Checkpatch Cleanup
In-Reply-To: <cover.1466279901.git.craig@craiginches.com>
References: <cover.1466279901.git.craig@craiginches.com>
Message-ID: <109b0da96b67ae70145433b585ada631a5f7c668.1466279901.git.craig@craiginches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Macros with complex values should be enclosed in parenthesis

Signed-off-by: Craig Inches <craig@craiginches.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 3004625..712355a 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1207,8 +1207,8 @@ struct cl_lock_descr {
 
 #define DDESCR "%s(%d):[%lu, %lu]:%x"
 #define PDESCR(descr)						   \
-	cl_lock_mode_name((descr)->cld_mode), (descr)->cld_mode,	\
-	(descr)->cld_start, (descr)->cld_end, (descr)->cld_enq_flags
+	(cl_lock_mode_name((descr)->cld_mode), (descr)->cld_mode,	\
+	(descr)->cld_start, (descr)->cld_end, (descr)->cld_enq_flags)
 
 const char *cl_lock_mode_name(const enum cl_lock_mode mode);
 
-- 
2.7.3
