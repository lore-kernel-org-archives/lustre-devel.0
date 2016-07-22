From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:47 -0400
Subject: [lustre-devel] [PATCH 54/58] staging: lustre: reorder LOV_MAGIC_*
	definition
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-55-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

Since all the LOV_MAGIC_* definitions have the same
postfix values break that value out into its own
definition. With this we can check whether the magic's
postfix match the LOV_MAGIC_MAGIC or not: if yes,
then it is quite possible that the clients has
encountered an newer LOV magic. This extra information
can let us handle those cases more gracefully.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4941
Reviewed-on: http://review.whamcloud.com/10045
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index d3a9db9..3444add 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1478,11 +1478,21 @@ enum obdo_flags {
 	OBD_FL_LOCAL_MASK   = 0xF0000000,
 };
 
-#define LOV_MAGIC_V1      0x0BD10BD0
-#define LOV_MAGIC	 LOV_MAGIC_V1
-#define LOV_MAGIC_JOIN_V1 0x0BD20BD0
-#define LOV_MAGIC_V3      0x0BD30BD0
-#define LOV_MAGIC_MIGRATE 0x0BD40BD0
+/*
+ * All LOV EA magics should have the same postfix, if some new version
+ * Lustre instroduces new LOV EA magic, then when down-grade to an old
+ * Lustre, even though the old version system does not recognizes such
+ * new magic, it still can distinguish the corrupted cases by checking
+ * the magic's postfix.
+ */
+#define LOV_MAGIC_MAGIC 0x0BD0
+#define LOV_MAGIC_MASK  0xFFFF
+
+#define LOV_MAGIC_V1		(0x0BD10000 | LOV_MAGIC_MAGIC)
+#define LOV_MAGIC_JOIN_V1	(0x0BD20000 | LOV_MAGIC_MAGIC)
+#define LOV_MAGIC_V3		(0x0BD30000 | LOV_MAGIC_MAGIC)
+#define LOV_MAGIC_MIGRATE	(0x0BD40000 | LOV_MAGIC_MAGIC)
+#define LOV_MAGIC		LOV_MAGIC_V1
 
 /*
  * magic for fully defined striping
-- 
1.7.1
