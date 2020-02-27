From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:15 -0500
Subject: [lustre-devel] [PATCH 147/622] lustre: idl: use proper
 ATTR/MDS_ATTR/MDS_OPEN flags
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-148-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Add proper MDS_ATTR_* and MDS_OPEN_* flags for different flags
namespaces.  The MDS_OPEN_OWNEROVERRIDE was being mapped into
the MDS_ATTR_* flags in some cases.  This did not conflict yet, but
add separate ATTR_OVERRIDE and MDS_ATTR_OVERRIDE flags for this use
so they don't conflict in the future.

Remove the MDS_OPEN_CROSS flag, since this was only used internally
as a hack to pass open flags to mdd_permission(), but was truncating
the u64 open flags to a 32-bit int in the process.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10030
Lustre-commit: 9c2ffe39bd32 ("LU-10030 idl: use proper ATTR/MDS_ATTR/MDS_OPEN flags")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32107
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c             | 6 ++----
 include/uapi/linux/lustre/lustre_idl.h  | 1 +
 include/uapi/linux/lustre/lustre_user.h | 2 +-
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index c6dd256..f72e5fc 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -251,8 +251,6 @@ void lustre_assert_wire_constants(void)
 		 (long long)MDS_ATTR_KILL_SGID);
 	LASSERTF(MDS_ATTR_CTIME_SET == 0x0000000000002000ULL, "found 0x%.16llxULL\n",
 		 (long long)MDS_ATTR_CTIME_SET);
-	LASSERTF(MDS_ATTR_FROM_OPEN == 0x0000000000004000ULL, "found 0x%.16llxULL\n",
-		 (long long)MDS_ATTR_FROM_OPEN);
 	LASSERTF(MDS_ATTR_BLOCKS == 0x0000000000008000ULL, "found 0x%.16llxULL\n",
 		 (long long)MDS_ATTR_BLOCKS);
 	LASSERTF(MDS_ATTR_PROJID == 0x0000000000010000ULL, "found 0x%.16llxULL\n",
@@ -262,6 +260,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)MDS_ATTR_LSIZE);
 	LASSERTF(MDS_ATTR_LBLOCKS == 0x0000000000040000ULL, "found 0x%.16llxULL\n",
 		 (long long)MDS_ATTR_LBLOCKS);
+	LASSERTF(MDS_ATTR_OVERRIDE == 0x0000000002000000ULL, "found 0x%.16llxULL\n",
+		 (long long)MDS_ATTR_OVERRIDE);
 	LASSERTF(FLD_QUERY == 900, "found %lld\n",
 		 (long long)FLD_QUERY);
 	LASSERTF(FLD_FIRST_OPC == 900, "found %lld\n",
@@ -2094,8 +2094,6 @@ void lustre_assert_wire_constants(void)
 		 MDS_FMODE_EXEC);
 	LASSERTF(MDS_OPEN_CREATED == 000000000010UL, "found 0%.11oUL\n",
 		 MDS_OPEN_CREATED);
-	LASSERTF(MDS_OPEN_CROSS == 000000000020UL, "found 0%.11oUL\n",
-		 MDS_OPEN_CROSS);
 	LASSERTF(MDS_OPEN_CREAT == 000000000100UL, "found 0%.11oUL\n",
 		 MDS_OPEN_CREAT);
 	LASSERTF(MDS_OPEN_EXCL == 000000000200UL, "found 0%.11oUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 2f15671..d46a921 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1681,6 +1681,7 @@ struct mdt_rec_setattr {
 #define MDS_ATTR_PROJID		0x10000ULL /* = 65536 */
 #define MDS_ATTR_LSIZE		0x20000ULL /* = 131072 */
 #define MDS_ATTR_LBLOCKS	0x40000ULL /* = 262144 */
+#define MDS_ATTR_OVERRIDE	0x2000000ULL /* = 33554432 */
 
 enum mds_op_bias {
 /*	MDS_CHECK_SPLIT		= 1 << 0, obsolete before 2.3.58 */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 844e50e..db751d8 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -922,7 +922,7 @@ enum la_valid {
 /*	MDS_FMODE_SOM		04000000 obsolete since 2.8.0 */
 
 #define MDS_OPEN_CREATED	00000010
-#define MDS_OPEN_CROSS		00000020
+/*	MDS_OPEN_CROSS		00000020 obsolete in 2.12, internal use only */
 
 #define MDS_OPEN_CREAT		00000100
 #define MDS_OPEN_EXCL		00000200
-- 
1.8.3.1
