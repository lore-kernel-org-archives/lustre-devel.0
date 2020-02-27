From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:49 -0500
Subject: [lustre-devel] [PATCH 541/622] lustre: ptlrpc: update wiretest for
 new values
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-542-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Update wiretest.c file to fixes issues with some #defines that were
changed to named enums. Don't need to wire check posix acl structures
if CONFIG_FS_POSIX_ACL is disabled.

Fixes: cd7fd3b2e230 ("lustre: obd: add rmfid support")
Fixes: c52da9b97ee0 ("lustre: introduce CONFIG_LUSTRE_FS_POSIX_ACL")
Fixes: 0b75bfcd14ac ("lustre: uapi: Add nonrotational flag to statfs")

WC-bug-id: https://jira.whamcloud.com/browse/LU-12937
Lustre-commit: bc2e23e1cd80 ("LU-12937 utils: update wirecheck for new values")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36706
Reviewed-by: Artem Blagodarenko <c17828@cray.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 671878d..9fc7a5b 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1748,19 +1748,19 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obd_statfs, os_spare9));
 	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_spare9) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_statfs *)0)->os_spare9));
-	LASSERTF(OS_STATE_DEGRADED == 0x1, "found %lld\n",
+	LASSERTF(OS_STATE_DEGRADED == 0x00000001UL, "found %lld\n",
 		 (long long)OS_STATE_DEGRADED);
-	LASSERTF(OS_STATE_READONLY == 0x2, "found %lld\n",
+	LASSERTF(OS_STATE_READONLY == 0x00000002UL, "found %lld\n",
 		 (long long)OS_STATE_READONLY);
-	LASSERTF(OS_STATE_NOPRECREATE == 0x4, "found %lld\n",
+	LASSERTF(OS_STATE_NOPRECREATE == 0x00000004UL, "found %lld\n",
 		 (long long)OS_STATE_NOPRECREATE);
-	LASSERTF(OS_STATE_ENOSPC == 0x20, "found %lld\n",
+	LASSERTF(OS_STATE_ENOSPC == 0x00000020UL, "found %lld\n",
 		 (long long)OS_STATE_ENOSPC);
-	LASSERTF(OS_STATE_ENOINO == 0x40, "found %lld\n",
+	LASSERTF(OS_STATE_ENOINO == 0x00000040UL, "found %lld\n",
 		 (long long)OS_STATE_ENOINO);
-	LASSERTF(OS_STATE_SUM == 0x100, "found %lld\n",
+	LASSERTF(OS_STATE_SUM == 0x00000100UL, "found %lld\n",
 		 (long long)OS_STATE_SUM);
-	LASSERTF(OS_STATE_NONROT == 0x200, "found %lld\n",
+	LASSERTF(OS_STATE_NONROT == 0x00000200UL, "found %lld\n",
 		 (long long)OS_STATE_NONROT);
 
 	/* Checks for struct obd_ioobj */
@@ -2178,19 +2178,19 @@ void lustre_assert_wire_constants(void)
 		 LUSTRE_DIRECTIO_FL);
 	LASSERTF(LUSTRE_INLINE_DATA_FL == 0x10000000, "found 0x%.8x\n",
 		 LUSTRE_INLINE_DATA_FL);
-	LASSERTF(MDS_INODELOCK_LOOKUP == 0x000001, "found 0x%.8x\n",
+	LASSERTF(MDS_INODELOCK_LOOKUP == 0x00000001UL, "found 0x%.8x\n",
 		 MDS_INODELOCK_LOOKUP);
-	LASSERTF(MDS_INODELOCK_UPDATE == 0x000002, "found 0x%.8x\n",
+	LASSERTF(MDS_INODELOCK_UPDATE == 0x00000002UL, "found 0x%.8x\n",
 		 MDS_INODELOCK_UPDATE);
-	LASSERTF(MDS_INODELOCK_OPEN == 0x000004, "found 0x%.8x\n",
+	LASSERTF(MDS_INODELOCK_OPEN == 0x00000004UL, "found 0x%.8x\n",
 		 MDS_INODELOCK_OPEN);
-	LASSERTF(MDS_INODELOCK_LAYOUT == 0x000008, "found 0x%.8x\n",
+	LASSERTF(MDS_INODELOCK_LAYOUT == 0x00000008UL, "found 0x%.8x\n",
 		 MDS_INODELOCK_LAYOUT);
-	LASSERTF(MDS_INODELOCK_PERM == 0x000010, "found 0x%.8x\n",
+	LASSERTF(MDS_INODELOCK_PERM == 0x00000010UL, "found 0x%.8x\n",
 		MDS_INODELOCK_PERM);
-	LASSERTF(MDS_INODELOCK_XATTR == 0x000020, "found 0x%.8x\n",
+	LASSERTF(MDS_INODELOCK_XATTR == 0x00000020UL, "found 0x%.8x\n",
 		MDS_INODELOCK_XATTR);
-	LASSERTF(MDS_INODELOCK_DOM == 0x000040, "found 0x%.8x\n",
+	LASSERTF(MDS_INODELOCK_DOM == 0x00000040UL, "found 0x%.8x\n",
 		MDS_INODELOCK_DOM);
 
 	/* Checks for struct mdt_ioepoch */
@@ -4176,6 +4176,7 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(FIEMAP_EXTENT_NO_DIRECT != 0x40000000);
 	BUILD_BUG_ON(FIEMAP_EXTENT_NET != 0x80000000);
 
+#ifdef CONFIG_FS_POSIX_ACL
 	/* Checks for type posix_acl_xattr_entry */
 	LASSERTF((int)sizeof(struct posix_acl_xattr_entry) == 8, "found %lld\n",
 		 (long long)(int)sizeof(struct posix_acl_xattr_entry));
@@ -4199,6 +4200,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct posix_acl_xattr_header, a_version));
 	LASSERTF((int)sizeof(((struct posix_acl_xattr_header *)0)->a_version) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct posix_acl_xattr_header *)0)->a_version));
+#endif /* CONFIG_FS_POSIX_ACL */
 
 	/* Checks for struct link_ea_header */
 	LASSERTF((int)sizeof(struct link_ea_header) == 24, "found %lld\n",
-- 
1.8.3.1
