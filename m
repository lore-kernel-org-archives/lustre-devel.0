From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:59 -0500
Subject: [lustre-devel] [PATCH 25/28] lustre: uapi: support negative flags
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

'flags' can be negative flags.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/26490
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index b19adef..833a57a 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -413,9 +413,12 @@ enum lov_comp_md_entry_flags {
 	LCME_FL_OFFLINE		= 0x00000004,   /* Not used */
 	LCME_FL_PREFERRED	= 0x00000008,	/* Not used */
 	LCME_FL_INIT		= 0x00000010,	/* instantiated */
+	LCME_FL_NEG		= 0x80000000,	/* used to indicate a negative
+						 * flag, won't be stored on disk
+						 */
 };
 
-#define LCME_KNOWN_FLAGS	LCME_FL_INIT
+#define LCME_KNOWN_FLAGS	(LCME_FL_NEG | LCME_FL_INIT)
 
 /* lcme_id can be specified as certain flags, and the the first
  * bit of lcme_id is used to indicate that the ID is representing
@@ -426,7 +429,7 @@ enum lcme_id {
 	LCME_ID_INVAL	= 0x0,
 	LCME_ID_MAX	= 0x7FFFFFFF,
 	LCME_ID_ALL	= 0xFFFFFFFF,
-	LCME_ID_NONE	= 0x80000000
+	LCME_ID_NOT_ID	= LCME_FL_NEG
 };
 
 #define LCME_ID_MASK	LCME_ID_MAX
-- 
1.8.3.1
