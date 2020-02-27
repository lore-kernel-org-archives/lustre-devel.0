From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:24 -0500
Subject: [lustre-devel] [PATCH 036/622] lustre: mds: remove obsolete
 MDS_VTX_BYPASS flag
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The MDS_VTX_BYPASS flag is only set and never checked.  This is true
since 2.3.53-66-g54fe979 "LU-2216 mdt: remove obsolete DNE code", but
it was already obsolete for a long time before that.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6349
Lustre-commit: b99344dda425 ("LU-6349 mds: remove obsolete MDS_VTX_BYPASS flag")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31984
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c            | 2 --
 include/uapi/linux/lustre/lustre_idl.h | 4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 46d5e74..c92663b 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1870,8 +1870,6 @@ void lustre_assert_wire_constants(void)
 
 	LASSERTF(MDS_CROSS_REF == 0x00000002UL, "found 0x%.8xUL\n",
 		(unsigned int)MDS_CROSS_REF);
-	LASSERTF(MDS_VTX_BYPASS == 0x00000004UL, "found 0x%.8xUL\n",
-		(unsigned int)MDS_VTX_BYPASS);
 	LASSERTF(MDS_PERM_BYPASS == 0x00000008UL, "found 0x%.8xUL\n",
 		(unsigned int)MDS_PERM_BYPASS);
 	LASSERTF(MDS_QUOTA_IGNORE == 0x00000020UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index e898e67..794e6d6 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1644,11 +1644,11 @@ struct mdt_rec_setattr {
 enum mds_op_bias {
 /*	MDS_CHECK_SPLIT		= 1 << 0, obsolete before 2.3.58 */
 	MDS_CROSS_REF		= 1 << 1,
-	MDS_VTX_BYPASS		= 1 << 2,
+/*	MDS_VTX_BYPASS		= 1 << 2, obsolete since 2.3.54 */
 	MDS_PERM_BYPASS		= 1 << 3,
 /*	MDS_SOM			= 1 << 4, obsolete since 2.8.0 */
 	MDS_QUOTA_IGNORE	= 1 << 5,
-	MDS_CLOSE_CLEANUP	= 1 << 6,
+/*	MDS_CLOSE_CLEANUP	= 1 << 6, obsolete since 2.3.51 */
 	MDS_KEEP_ORPHAN		= 1 << 7,
 	MDS_RECOV_OPEN		= 1 << 8,
 	MDS_DATA_MODIFIED	= 1 << 9,
-- 
1.8.3.1
