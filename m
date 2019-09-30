From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:23 -0400
Subject: [lustre-devel] [PATCH 124/151] lustre: uapi: record denied OPEN in
 Changelogs
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-125-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Record denied OPEN events in Changelogs, in the same format as
successful OPEN events.
Recording denied OPEN events is useful for security audit,
in order to find out who tried to get access to some data.
An NOPEN changlog entry is in the form:
4 24NOPEN 15:45:44.947406626 2017.08.31 0x2 t=[0x200000402:0x1:0x0]
ef=0xf u=500:500 nid=10.128.11.158 at tcp m=-w-
By default, disable recording of NOPEN events in Changelogs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9727
Lustre-commit: ccb6fe4b5994 ("LU-9727 lustre: record denied OPEN in Changelogs")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/28812
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Matthew S <matthew.sanderson@anu.edu.au>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 8a529a1..29be243 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -941,6 +941,7 @@ enum changelog_rec_type {
 	CL_FLRW		= 21, /* FLR: file was firstly written */
 	CL_RESYNC	= 22, /* FLR: file was resync-ed */
 	CL_GETXATTR	= 23,
+	CL_DN_OPEN	= 24, /* denied open */
 	CL_LAST
 };
 
@@ -950,7 +951,7 @@ static inline const char *changelog_type2str(int type)
 		"MARK",  "CREAT", "MKDIR", "HLINK", "SLINK", "MKNOD", "UNLNK",
 		"RMDIR", "RENME", "RNMTO", "OPEN",  "CLOSE", "LYOUT", "TRUNC",
 		"SATTR", "XATTR", "HSM",   "MTIME", "CTIME", "ATIME", "",
-		"FLRW",  "RESYNC", "GXATTR",
+		"FLRW",  "RESYNC", "GXATTR", "NOPEN",
 	};
 
 	if (type >= 0 && type < CL_LAST)
-- 
1.8.3.1
