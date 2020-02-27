From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:14 -0500
Subject: [lustre-devel] [PATCH 446/622] lustre: uapi: Remove unused CONNECT
 flag
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-447-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

The plain layout connect flag was added as part of an
earlier implementation of LU-11213, but the design was
improved before landing and the flag was not needed.

Let's remove it.  Since it was never actually marked as
supported in any client/server version, we can just remove
it entirely, leaving the flag bit open for future use.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11213
Lustre-commit: 11eba11fe045 ("LU-11213 uapi: Remove unused CONNECT flag")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36008
Reviewed-by: Shilong Wang <wshilong@ddn.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c            | 2 --
 include/uapi/linux/lustre/lustre_idl.h | 1 -
 2 files changed, 3 deletions(-)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 9298c97..c0b4ad9 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1158,8 +1158,6 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_LSOM);
 	LASSERTF(OBD_CONNECT2_PCC == 0x1000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_PCC);
-	LASSERTF(OBD_CONNECT2_PLAIN_LAYOUT == 0x2000ULL, "found 0x%.16llxULL\n",
-		 OBD_CONNECT2_PLAIN_LAYOUT);
 	LASSERTF(OBD_CONNECT2_ASYNC_DISCARD == 0x4000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ASYNC_DISCARD);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 87251ee..47321ae 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -810,7 +810,6 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_SELINUX_POLICY    0x400ULL	/* has client SELinux policy */
 #define OBD_CONNECT2_LSOM	       0x800ULL	/* LSOM support */
 #define OBD_CONNECT2_PCC	       0x1000ULL /* Persistent Client Cache */
-#define OBD_CONNECT2_PLAIN_LAYOUT      0x2000ULL /* Plain Directory Layout */
 #define OBD_CONNECT2_ASYNC_DISCARD     0x4000ULL /* support async DoM data
 						  * discard
 						  */
-- 
1.8.3.1
