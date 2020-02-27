From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:55 -0500
Subject: [lustre-devel] [PATCH 307/622] lustre: uapi: Add nonrotational flag
 to statfs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-308-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

It is potentially useful for the MDS and userspace to
know whether or not an OST is using non-rotational media.

Add a flag to obd_statfs that reflects this.

Users can override this parameter in sysfs.

ZFS does not currently make this information available to
Lustre, so default to rotational and allow users to
override.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11963
Lustre-commit: 68635c3d9b31 ("LU-11963 osd: Add nonrotational flag to statfs")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34235
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c             | 14 ++++++++++++++
 include/uapi/linux/lustre/lustre_user.h |  1 +
 2 files changed, 15 insertions(+)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index b8b561c..64ccc6e 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1745,6 +1745,20 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obd_statfs, os_spare9));
 	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_spare9) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_statfs *)0)->os_spare9));
+	LASSERTF(OS_STATE_DEGRADED == 0x1, "found %lld\n",
+		 (long long)OS_STATE_DEGRADED);
+	LASSERTF(OS_STATE_READONLY == 0x2, "found %lld\n",
+		 (long long)OS_STATE_READONLY);
+	LASSERTF(OS_STATE_NOPRECREATE == 0x4, "found %lld\n",
+		 (long long)OS_STATE_NOPRECREATE);
+	LASSERTF(OS_STATE_ENOSPC == 0x20, "found %lld\n",
+		 (long long)OS_STATE_ENOSPC);
+	LASSERTF(OS_STATE_ENOINO == 0x40, "found %lld\n",
+		 (long long)OS_STATE_ENOINO);
+	LASSERTF(OS_STATE_SUM == 0x100, "found %lld\n",
+		 (long long)OS_STATE_SUM);
+	LASSERTF(OS_STATE_NONROT == 0x200, "found %lld\n",
+		 (long long)OS_STATE_NONROT);
 
 	/* Checks for struct obd_ioobj */
 	LASSERTF((int)sizeof(struct obd_ioobj) == 24, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 22a0144..d66c883 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -105,6 +105,7 @@ enum obd_statfs_state {
 	OS_STATE_ENOSPC		= 0x00000020, /**< not enough free space */
 	OS_STATE_ENOINO		= 0x00000040, /**< not enough inodes */
 	OS_STATE_SUM		= 0x00000100, /**< aggregated for all tagrets */
+	OS_STATE_NONROT		= 0x00000200, /**< non-rotational device */
 };
 
 struct obd_statfs {
-- 
1.8.3.1
