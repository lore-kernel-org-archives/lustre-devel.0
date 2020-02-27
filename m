From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:13 -0500
Subject: [lustre-devel] [PATCH 385/622] lustre: mdt: improve IBITS lock
 definitions
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-386-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Move MDS_INODELOCK_* flags into a named enum, and add the definitions
for the newer flags into wirecheck/wiretest to ensure consistency.

Rename MDS_INODELOCK_MAXSHIFT to MDS_INODELOCK_NUMBITS to hold current
number of lockbits, rather than one less than the number of lockbits,
since the only two places that use it expect it to be one larger than
it is.  Fix uses of MDS_INODELOCK_NUMBITS to be number of locks.  This
does not change the value of MDS_INODELOCK_FULL, which is used in the
protocol to exchange supported lock bits between client and server.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11285
Lustre-commit: 3611352b699c ("LU-11285 mdt: improve IBITS lock definitions")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35045
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                 |  2 +-
 fs/lustre/ptlrpc/wiretest.c            |  6 ++++
 include/uapi/linux/lustre/lustre_idl.h | 51 +++++++++++++++++-----------------
 3 files changed, 32 insertions(+), 27 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index a20896c..d313730 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4323,7 +4323,7 @@ int ll_have_md_lock(struct inode *inode, u64 *bits,
 	       ldlm_lockname[mode]);
 
 	flags = LDLM_FL_BLOCK_GRANTED | LDLM_FL_CBPENDING | LDLM_FL_TEST_LOCK;
-	for (i = 0; i <= MDS_INODELOCK_MAXSHIFT && *bits != 0; i++) {
+	for (i = 0; i < MDS_INODELOCK_NUMBITS && *bits != 0; i++) {
 		policy.l_inodebits.bits = *bits & (1 << i);
 		if (policy.l_inodebits.bits == 0)
 			continue;
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index e801f2c..adc71ff 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -2185,6 +2185,12 @@ void lustre_assert_wire_constants(void)
 		 MDS_INODELOCK_OPEN);
 	LASSERTF(MDS_INODELOCK_LAYOUT == 0x000008, "found 0x%.8x\n",
 		 MDS_INODELOCK_LAYOUT);
+	LASSERTF(MDS_INODELOCK_PERM == 0x000010, "found 0x%.8x\n",
+		MDS_INODELOCK_PERM);
+	LASSERTF(MDS_INODELOCK_XATTR == 0x000020, "found 0x%.8x\n",
+		MDS_INODELOCK_XATTR);
+	LASSERTF(MDS_INODELOCK_DOM == 0x000040, "found 0x%.8x\n",
+		MDS_INODELOCK_DOM);
 
 	/* Checks for struct mdt_ioepoch */
 	LASSERTF((int)sizeof(struct mdt_ioepoch) == 24, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index c86b188..5acf781 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1482,33 +1482,32 @@ enum mdt_reint_cmd {
 #define DISP_OPEN_DENY		0x10000000
 
 /* INODE LOCK PARTS */
-#define MDS_INODELOCK_LOOKUP	0x000001	/*
-						 * For namespace, dentry etc, and
-						 * also was used to protect
-						 * permission (mode, owner, group
-						 * etc) before 2.4.
-						 */
-#define MDS_INODELOCK_UPDATE	0x000002	/* size, links, timestamps */
-#define MDS_INODELOCK_OPEN	0x000004	/* For opened files */
-#define MDS_INODELOCK_LAYOUT	0x000008	/* for layout */
-
-/* The PERM bit is added int 2.4, and it is used to protect permission(mode,
- * owner, group, acl etc), so to separate the permission from LOOKUP lock.
- * Because for remote directories(in DNE), these locks will be granted by
- * different MDTs(different ldlm namespace).
- *
- * For local directory, MDT will always grant UPDATE_LOCK|PERM_LOCK together.
- * For Remote directory, the master MDT, where the remote directory is, will
- * grant UPDATE_LOCK|PERM_LOCK, and the remote MDT, where the name entry is,
- * will grant LOOKUP_LOCK.
- */
-#define MDS_INODELOCK_PERM	0x000010
-#define MDS_INODELOCK_XATTR	0x000020	/* extended attributes */
-#define MDS_INODELOCK_DOM    0x000040 /* Data for data-on-mdt files */
-
-#define MDS_INODELOCK_MAXSHIFT 6
+enum mds_ibits_locks {
+	MDS_INODELOCK_LOOKUP	= 0x000001, /* For namespace, dentry etc.  Was
+					     * used to protect permission (mode,
+					     * owner, group, etc) before 2.4.
+					     */
+	MDS_INODELOCK_UPDATE	= 0x000002, /* size, links, timestamps */
+	MDS_INODELOCK_OPEN	= 0x000004, /* For opened files */
+	MDS_INODELOCK_LAYOUT	= 0x000008, /* for layout */
+
+	/* The PERM bit is added in 2.4, and is used to protect permission
+	 * (mode, owner, group, ACL, etc.) separate from LOOKUP lock.
+	 * For remote directories (in DNE) these locks will be granted by
+	 * different MDTs (different LDLM namespace).
+	 *
+	 * For local directory, the MDT always grants UPDATE|PERM together.
+	 * For remote directory, master MDT (where remote directory is) grants
+	 * UPDATE|PERM, and remote MDT (where name entry is) grants LOOKUP_LOCK.
+	 */
+	MDS_INODELOCK_PERM	= 0x000010,
+	MDS_INODELOCK_XATTR	= 0x000020, /* non-permission extended attrs */
+	MDS_INODELOCK_DOM	= 0x000040, /* Data for Data-on-MDT files */
+	/* Do not forget to increase MDS_INODELOCK_NUMBITS when adding bits */
+};
+#define MDS_INODELOCK_NUMBITS 7
 /* This FULL lock is useful to take on unlink sort of operations */
-#define MDS_INODELOCK_FULL ((1 << (MDS_INODELOCK_MAXSHIFT + 1)) - 1)
+#define MDS_INODELOCK_FULL ((1 << MDS_INODELOCK_NUMBITS) - 1)
 /* DOM lock shouldn't be canceled early, use this macro for ELC */
 #define MDS_INODELOCK_ELC (MDS_INODELOCK_FULL & ~MDS_INODELOCK_DOM)
 
-- 
1.8.3.1
