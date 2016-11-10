From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:31:05 -0500
Subject: [lustre-devel] [PATCH 35/35] staging: lustre: idl: clean up file
	attribute flags
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Remove unused file attribute flag LUSTRE_BFLAG_UNCOMMITTED_WRITES
that was used internally on the client at one point.

Add flags from the kernel which may be useful in the near future.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5017
Reviewed-on: http://review.whamcloud.com/10274
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    9 ++++++---
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   12 ++++++++++--
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index b8ddebd..5c1fb6c 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1924,16 +1924,19 @@ enum {
 #define MDS_STATUS_CONN 1
 #define MDS_STATUS_LOV 2
 
-#define LUSTRE_BFLAG_UNCOMMITTED_WRITES   0x1
-
 /* these should be identical to their EXT4_*_FL counterparts, they are
  * redefined here only to avoid dragging in fs/ext4/ext4.h
  */
 #define LUSTRE_SYNC_FL	 0x00000008 /* Synchronous updates */
 #define LUSTRE_IMMUTABLE_FL    0x00000010 /* Immutable file */
 #define LUSTRE_APPEND_FL       0x00000020 /* writes to file may only append */
+#define LUSTRE_NODUMP_FL	0x00000040 /* do not dump file */
 #define LUSTRE_NOATIME_FL      0x00000080 /* do not update atime */
+#define LUSTRE_INDEX_FL		0x00001000 /* hash-indexed directory */
 #define LUSTRE_DIRSYNC_FL      0x00010000 /* dirsync behaviour (dir only) */
+#define LUSTRE_TOPDIR_FL	0x00020000 /* Top of directory hierarchies*/
+#define LUSTRE_DIRECTIO_FL	0x00100000 /* Use direct i/o */
+#define LUSTRE_INLINE_DATA_FL	0x10000000 /* Inode has inline data. */
 
 /* Convert wire LUSTRE_*_FL to corresponding client local VFS S_* values
  * for the client inode i_flags.  The LUSTRE_*_FL are the Lustre wire
@@ -1986,7 +1989,7 @@ struct mdt_body {
 	__u32	mbo_mode;
 	__u32	mbo_uid;
 	__u32	mbo_gid;
-	__u32	mbo_flags;
+	__u32	mbo_flags;	/* LUSTRE_*_FL file attributes */
 	__u32	mbo_rdev;
 	__u32	mbo_nlink;	/* #bytes to read in the case of MDS_READPAGE */
 	__u32	mbo_unused2;	/* was "generation" until 2.4.0 */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 485ac88..b239563 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -218,8 +218,6 @@ void lustre_assert_wire_constants(void)
 		 (long long)MDS_STATUS_CONN);
 	LASSERTF(MDS_STATUS_LOV == 2, "found %lld\n",
 		 (long long)MDS_STATUS_LOV);
-	LASSERTF(LUSTRE_BFLAG_UNCOMMITTED_WRITES == 1, "found %lld\n",
-		 (long long)LUSTRE_BFLAG_UNCOMMITTED_WRITES);
 	LASSERTF(MDS_ATTR_MODE == 0x0000000000000001ULL, "found 0x%.16llxULL\n",
 		 (long long)MDS_ATTR_MODE);
 	LASSERTF(MDS_ATTR_UID == 0x0000000000000002ULL, "found 0x%.16llxULL\n",
@@ -1927,10 +1925,20 @@ void lustre_assert_wire_constants(void)
 		 LUSTRE_IMMUTABLE_FL);
 	LASSERTF(LUSTRE_APPEND_FL == 0x00000020, "found 0x%.8x\n",
 		 LUSTRE_APPEND_FL);
+	LASSERTF(LUSTRE_NODUMP_FL == 0x00000040, "found 0x%.8x\n",
+		 LUSTRE_NODUMP_FL);
 	LASSERTF(LUSTRE_NOATIME_FL == 0x00000080, "found 0x%.8x\n",
 		 LUSTRE_NOATIME_FL);
+	LASSERTF(LUSTRE_INDEX_FL == 0x00001000, "found 0x%.8x\n",
+		 LUSTRE_INDEX_FL);
 	LASSERTF(LUSTRE_DIRSYNC_FL == 0x00010000, "found 0x%.8x\n",
 		 LUSTRE_DIRSYNC_FL);
+	LASSERTF(LUSTRE_TOPDIR_FL == 0x00020000, "found 0x%.8x\n",
+		 LUSTRE_TOPDIR_FL);
+	LASSERTF(LUSTRE_DIRECTIO_FL == 0x00100000, "found 0x%.8x\n",
+		 LUSTRE_DIRECTIO_FL);
+	LASSERTF(LUSTRE_INLINE_DATA_FL == 0x10000000, "found 0x%.8x\n",
+		 LUSTRE_INLINE_DATA_FL);
 	LASSERTF(MDS_INODELOCK_LOOKUP == 0x000001, "found 0x%.8x\n",
 		 MDS_INODELOCK_LOOKUP);
 	LASSERTF(MDS_INODELOCK_UPDATE == 0x000002, "found 0x%.8x\n",
-- 
1.7.1
