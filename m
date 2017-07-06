From: Jaya Durga <rjdurga@gmail.com>
Date: Thu,  6 Jul 2017 12:43:15 +0530
Subject: [lustre-devel] [PATCH 8/8] Staging: lustre :lustre: include
	:lustre_compat.h: Prefer using the BIT macro
Message-ID: <1499325195-17466-1-git-send-email-rjdurga@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gregkh@linuxfoundation.org
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, john.hammond@intel.com, bobijam@hotmail.com, mingo@kernel.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Jaya Durga <rjdurga@gmail.com>

Replace all instances of (1 << 27) with BIT(27) to fix
checkpatch check messages

Signed-off-by: Jaya Durga <rjdurga@gmail.com>
---
 drivers/staging/lustre/lustre/include/lustre_compat.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index da9ce19..686a251 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -43,7 +43,7 @@
  * set ATTR_BLOCKS to a high value to avoid any risk of collision with other
  * ATTR_* attributes (see bug 13828)
  */
-#define ATTR_BLOCKS    (1 << 27)
+#define ATTR_BLOCKS    BIT(27)
 
 #define current_ngroups current_cred()->group_info->ngroups
 #define current_groups current_cred()->group_info->small_block
-- 
1.9.1
