From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:48 -0400
Subject: [lustre-devel] [PATCH 11/45] lustre: uapi: add OBD_CONNECT2_FIDMAP
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Add OBD_CONNECT2_FIDMAP connect flag, which indicates whether client
supports FID mapping.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11025
Lustre-commit: c96fa612d5b0f ("LU-11025 uapi: add OBD_CONNECT2_FIDMAP")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38232
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 2 files changed, 3 insertions(+)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index fee4be2..81d0a99 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1241,6 +1241,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_ASYNC_DISCARD);
 	LASSERTF(OBD_CONNECT2_ENCRYPT == 0x8000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ENCRYPT);
+	LASSERTF(OBD_CONNECT2_FIDMAP== 0x10000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_FIDMAP);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index f6f2761..fd880f3 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -818,6 +818,7 @@ struct ptlrpc_body_v2 {
 						  * discard
 						  */
 #define OBD_CONNECT2_ENCRYPT	       0x8000ULL /* client-to-disk encrypt */
+#define OBD_CONNECT2_FIDMAP	      0x10000ULL /* FID map */
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
  * flag value is not in use on some other branch.  Please clear any such
-- 
1.8.3.1
