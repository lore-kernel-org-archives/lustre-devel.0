From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 05/11] lustre: improve alignment in
 lustre_disk.h
In-Reply-To: <153067941050.30111.13691201276059352926.stgit@noble>
References: <153067941050.30111.13691201276059352926.stgit@noble>
Message-ID: <153067943073.30111.15126443210273103850.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Be more consistent with field and comment alignment.
Note that "git diff -b" shows no non-blank changes.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_disk.h    |   38 ++++++++++----------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index bd8fa717ff31..1a6d421ea64b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -70,23 +70,23 @@
 
 /* gleaned from the mount command - no persistent info here */
 struct lustre_mount_data {
-	__u32      lmd_magic;
-	__u32      lmd_flags;	 /* lustre mount flags */
+	__u32	lmd_magic;
+	__u32	lmd_flags;	/* lustre mount flags */
 	int	lmd_mgs_failnodes; /* mgs failover node count */
 	int	lmd_exclude_count;
 	int	lmd_recovery_time_soft;
 	int	lmd_recovery_time_hard;
-	char      *lmd_dev;	   /* device name */
-	char      *lmd_profile;    /* client only */
+	char	*lmd_dev;	/* device name */
+	char	*lmd_profile;	/* client only */
 	char	*lmd_fileset;	/* mount fileset */
-	char      *lmd_mgssec;	/* sptlrpc flavor to mgs */
-	char      *lmd_opts;	/* lustre mount options (as opposed to
+	char	*lmd_mgssec;	/* sptlrpc flavor to mgs */
+	char	*lmd_opts;	/* lustre mount options (as opposed to
 				 * _device_ mount options)
 				 */
-	char      *lmd_params;	/* lustre params */
-	__u32     *lmd_exclude; /* array of OSTs to ignore */
+	char	*lmd_params;	/* lustre params */
+	__u32	*lmd_exclude;	/* array of OSTs to ignore */
 	char	*lmd_mgs;	/* MGS nid */
-	char	*lmd_osd_type;  /* OSD type */
+	char	*lmd_osd_type;	/* OSD type */
 };
 
 #define LMD_FLG_SERVER		0x0001	/* Mounting a server */
@@ -115,21 +115,21 @@ struct lustre_mount_data {
 struct ll_sb_info;
 
 struct lustre_sb_info {
-	int		       lsi_flags;
+	int			lsi_flags;
 	struct obd_device	*lsi_mgc;     /* mgc obd */
 	struct lustre_mount_data *lsi_lmd;     /* mount command info */
 	struct ll_sb_info	*lsi_llsbi;   /* add'l client sbi info */
-	struct dt_device	 *lsi_dt_dev;  /* dt device to access disk fs*/
-	atomic_t	      lsi_mounts;  /* references to the srv_mnt */
-	char			  lsi_svname[MTI_NAME_MAXLEN];
-	char			  lsi_osd_obdname[64];
-	char			  lsi_osd_uuid[64];
-	struct obd_export	 *lsi_osd_exp;
-	char			  lsi_osd_type[16];
-	char			  lsi_fstype[16];
+	struct dt_device	*lsi_dt_dev;  /* dt device to access disk fs*/
+	atomic_t		lsi_mounts;  /* references to the srv_mnt */
+	char			lsi_svname[MTI_NAME_MAXLEN];
+	char			lsi_osd_obdname[64];
+	char			lsi_osd_uuid[64];
+	struct obd_export	*lsi_osd_exp;
+	char			lsi_osd_type[16];
+	char			lsi_fstype[16];
 };
 
-#define LSI_UMOUNT_FAILOVER	      0x00200000
+#define LSI_UMOUNT_FAILOVER	0x00200000
 
 #define     s2lsi(sb)	((struct lustre_sb_info *)((sb)->s_fs_info))
 #define     s2lsi_nocast(sb) ((sb)->s_fs_info)
