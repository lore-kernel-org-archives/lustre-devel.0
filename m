From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:51 -0500
Subject: [lustre-devel] [PATCH 063/622] lustre: ptlrpc: assign specific
 values to MGS opcodes
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-64-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Assign specific values to all of the MGS opcodes in enum mgs_cmd
so that these values do not change if a new items is added or one
is removed in the future.  These opcodes are part of the wire
protocol and need to remain constant.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10855
Lustre-commit: 12c5a26609f1 ("LU-10855 ptlrpc: assign specific values to MGS opcodes")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32653
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c            |  2 ++
 include/uapi/linux/lustre/lustre_idl.h | 20 ++++++++++----------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 015c5bd..ef07975 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -348,6 +348,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)MGS_TARGET_DEL);
 	LASSERTF(MGS_SET_INFO == 255, "found %lld\n",
 		 (long long)MGS_SET_INFO);
+	LASSERTF(MGS_CONFIG_READ == 256, "found %lld\n",
+		 (long long)MGS_CONFIG_READ);
 	LASSERTF(MGS_LAST_OPC == 257, "found %lld\n",
 		 (long long)MGS_LAST_OPC);
 	LASSERTF(SEC_CTX_INIT == 801, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index adaa994..1b5794a 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2247,16 +2247,16 @@ struct ldlm_reply {
  * Opcodes for mountconf (mgs and mgc)
  */
 enum mgs_cmd {
-	MGS_CONNECT = 250,
-	MGS_DISCONNECT,
-	MGS_EXCEPTION,		/* node died, etc. */
-	MGS_TARGET_REG,		/* whenever target starts up */
-	MGS_TARGET_DEL,
-	MGS_SET_INFO,
-	MGS_CONFIG_READ,
-	MGS_LAST_OPC
-};
-#define MGS_FIRST_OPC MGS_CONNECT
+	MGS_CONNECT	= 250,
+	MGS_DISCONNECT	= 251,
+	MGS_EXCEPTION	= 252,	/* node died, etc. */
+	MGS_TARGET_REG	= 253,	/* whenever target starts up */
+	MGS_TARGET_DEL	= 254,
+	MGS_SET_INFO	= 255,
+	MGS_CONFIG_READ	= 256,
+	MGS_LAST_OPC,
+	MGS_FIRST_OPC	= MGS_CONNECT
+};
 
 #define MGS_PARAM_MAXLEN 1024
 #define KEY_SET_INFO "set_info"
-- 
1.8.3.1
