From: James Simmons <jsimmons@infradead.org>
Date: Thu, 28 Apr 2016 12:07:38 -0400
Subject: [lustre-devel] [PATCH 8/8] staging: lustre: llite: quiet overly
	verbose info message
In-Reply-To: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
References: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461859658-22200-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

The client doesn't need to print a message for every client mount that
the layout lock feature is enabled.  This can be found at runtime via
the "import" proc file.

I also noticed that deleting OST objects logs into the debug log with
D_HA status, which is enabled by default.  Move this over to D_INODE
so it doesn't fill the OST debug logs.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1095
Reviewed-on: http://review.whamcloud.com/7918
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 8d88d4c..64be2c1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -331,10 +331,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	else
 		sbi->ll_md_brw_size = PAGE_SIZE;
 
-	if (data->ocd_connect_flags & OBD_CONNECT_LAYOUTLOCK) {
-		LCONSOLE_INFO("Layout lock feature supported.\n");
+	if (data->ocd_connect_flags & OBD_CONNECT_LAYOUTLOCK)
 		sbi->ll_flags |= LL_SBI_LAYOUT_LOCK;
-	}
 
 	if (data->ocd_ibits_known & MDS_INODELOCK_XATTR) {
 		if (!(data->ocd_connect_flags & OBD_CONNECT_MAX_EASIZE)) {
-- 
2.7.4
