From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:58 -0400
Subject: [lustre-devel] [PATCH 13/18] staging: lustre: hsm: Add
	CLF_RENAME_LAST flag
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, JC Lafoucriere <jacques-charles.lafoucriere@cea.fr>, James Simmons <jsimmons@infradead.org>

From: JC Lafoucriere <jacques-charles.lafoucriere@cea.fr>

Create a special flag for the last rename event.

Signed-off-by: JC Lafoucriere <jacques-charles.lafoucriere@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3718
Reviewed-on: http://review.whamcloud.com/7260
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_user.h     |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 4672145..e4e42e1 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -676,7 +676,12 @@ static inline const char *changelog_type2str(int type)
 #define CLF_UNLINK_HSM_EXISTS 0x0002 /* File has something in HSM */
 				     /* HSM cleaning needed */
 /* Flags for rename */
-#define CLF_RENAME_LAST       0x0001 /* rename unlink last hardlink of target */
+#define CLF_RENAME_LAST		0x0001	/* rename unlink last hardlink of
+					 * target
+					 */
+#define CLF_RENAME_LAST_EXISTS	0x0002	/* rename unlink last hardlink of target
+					 * has an archive in backend
+					 */
 
 /* Flags for HSM */
 /* 12b used (from high weight to low weight):
-- 
1.7.1
