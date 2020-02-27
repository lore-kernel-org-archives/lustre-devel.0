From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:07 -0500
Subject: [lustre-devel] [PATCH 259/622] lustre: uapi: reserve connect flag
 for plain layout
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-260-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Reserve OBD_CONNECT2_PLAIN_LAYOUT flag, so that client supporting
plain layout won't enable plain layout if MDT doesn't support,
and in contrary, MDT supporting plain layout won't send such layout
to client that doesn't support.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11213
Lustre-commit: 14ee65e77bdc ("LU-11213 uapi: reserve connect flag for plain layout")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34656
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 1 +
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 3 files changed, 4 insertions(+)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 254a600..a7c274a 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -124,6 +124,7 @@
 	"selinux_policy",	/* 0x400 */
 	"lsom",			/* 0x800 */
 	"pcc",			/* 0x1000 */
+	"plain_layout",		/* 0x2000 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 22447e2..4a268f6 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1150,6 +1150,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_LSOM);
 	LASSERTF(OBD_CONNECT2_PCC == 0x1000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_PCC);
+	LASSERTF(OBD_CONNECT2_PLAIN_LAYOUT == 0x2000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_PLAIN_LAYOUT);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 46c3369..1b4b018 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -808,6 +808,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_SELINUX_POLICY    0x400ULL	/* has client SELinux policy */
 #define OBD_CONNECT2_LSOM	       0x800ULL	/* LSOM support */
 #define OBD_CONNECT2_PCC	       0x1000ULL /* Persistent Client Cache */
+#define OBD_CONNECT2_PLAIN_LAYOUT      0x2000ULL /* Plain Directory Layout */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
-- 
1.8.3.1
