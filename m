From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:20 -0500
Subject: [lustre-devel] [PATCH v2 37/84] staging/lustre: Remove
	last_rcvd-file related data
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-38-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

last_rcvd (last received) is a special server-side file on the
Lustre FS that stores information about server filesystem and
also list of connected clients and their state. There's no
point in having any of tha ton the client, though.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre_disk.h    | 225 ---------------------
 1 file changed, 225 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 7c6933f..b69bd9d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -116,231 +116,6 @@ struct lustre_mount_data {
 #define LR_EXPIRE_INTERVALS 16 /**< number of intervals to track transno */
 #define ENOENT_VERSION 1 /** 'virtual' version of non-existent object */
 
-#define LR_SERVER_SIZE   512
-#define LR_CLIENT_START 8192
-#define LR_CLIENT_SIZE   128
-#if LR_CLIENT_START < LR_SERVER_SIZE
-#error "Can't have LR_CLIENT_START < LR_SERVER_SIZE"
-#endif
-
-/*
- * This limit is arbitrary (131072 clients on x86), but it is convenient to use
- * 2^n * PAGE_CACHE_SIZE * 8 for the number of bits that fit an order-n allocation.
- * If we need more than 131072 clients (order-2 allocation on x86) then this
- * should become an array of single-page pointers that are allocated on demand.
- */
-#if (128 * 1024UL) > (PAGE_CACHE_SIZE * 8)
-#define LR_MAX_CLIENTS (128 * 1024UL)
-#else
-#define LR_MAX_CLIENTS (PAGE_CACHE_SIZE * 8)
-#endif
-
-/** COMPAT_146: this is an OST (temporary) */
-#define OBD_COMPAT_OST	  0x00000002
-/** COMPAT_146: this is an MDT (temporary) */
-#define OBD_COMPAT_MDT	  0x00000004
-/** 2.0 server, interop flag to show server version is changed */
-#define OBD_COMPAT_20	   0x00000008
-
-/** MDS handles LOV_OBJID file */
-#define OBD_ROCOMPAT_LOVOBJID   0x00000001
-
-/** OST handles group subdirs */
-#define OBD_INCOMPAT_GROUPS     0x00000001
-/** this is an OST */
-#define OBD_INCOMPAT_OST	0x00000002
-/** this is an MDT */
-#define OBD_INCOMPAT_MDT	0x00000004
-/** common last_rvcd format */
-#define OBD_INCOMPAT_COMMON_LR  0x00000008
-/** FID is enabled */
-#define OBD_INCOMPAT_FID	0x00000010
-/** Size-on-MDS is enabled */
-#define OBD_INCOMPAT_SOM	0x00000020
-/** filesystem using iam format to store directory entries */
-#define OBD_INCOMPAT_IAM_DIR    0x00000040
-/** LMA attribute contains per-inode incompatible flags */
-#define OBD_INCOMPAT_LMA	0x00000080
-/** lmm_stripe_count has been shrunk from __u32 to __u16 and the remaining 16
- * bits are now used to store a generation. Once we start changing the layout
- * and bumping the generation, old versions expecting a 32-bit lmm_stripe_count
- * will be confused by interpreting stripe_count | gen << 16 as the actual
- * stripe count */
-#define OBD_INCOMPAT_LMM_VER    0x00000100
-/** multiple OI files for MDT */
-#define OBD_INCOMPAT_MULTI_OI   0x00000200
-
-/* Data stored per server@the head of the last_rcvd file.  In le32 order.
-   This should be common to filter_internal.h, lustre_mds.h */
-struct lr_server_data {
-	__u8  lsd_uuid[40];	/* server UUID */
-	__u64 lsd_last_transno;    /* last completed transaction ID */
-	__u64 lsd_compat14;	/* reserved - compat with old last_rcvd */
-	__u64 lsd_mount_count;     /* incarnation number */
-	__u32 lsd_feature_compat;  /* compatible feature flags */
-	__u32 lsd_feature_rocompat;/* read-only compatible feature flags */
-	__u32 lsd_feature_incompat;/* incompatible feature flags */
-	__u32 lsd_server_size;     /* size of server data area */
-	__u32 lsd_client_start;    /* start of per-client data area */
-	__u16 lsd_client_size;     /* size of per-client data area */
-	__u16 lsd_subdir_count;    /* number of subdirectories for objects */
-	__u64 lsd_catalog_oid;     /* recovery catalog object id */
-	__u32 lsd_catalog_ogen;    /* recovery catalog inode generation */
-	__u8  lsd_peeruuid[40];    /* UUID of MDS associated with this OST */
-	__u32 lsd_osd_index;       /* index number of OST in LOV */
-	__u32 lsd_padding1;	/* was lsd_mdt_index, unused in 2.4.0 */
-	__u32 lsd_start_epoch;     /* VBR: start epoch from last boot */
-	/** transaction values since lsd_trans_table_time */
-	__u64 lsd_trans_table[LR_EXPIRE_INTERVALS];
-	/** start point of transno table below */
-	__u32 lsd_trans_table_time; /* time of first slot in table above */
-	__u32 lsd_expire_intervals; /* LR_EXPIRE_INTERVALS */
-	__u8  lsd_padding[LR_SERVER_SIZE - 288];
-};
-
-/* Data stored per client in the last_rcvd file.  In le32 order. */
-struct lsd_client_data {
-	__u8  lcd_uuid[40];      /* client UUID */
-	__u64 lcd_last_transno; /* last completed transaction ID */
-	__u64 lcd_last_xid;     /* xid for the last transaction */
-	__u32 lcd_last_result;  /* result from last RPC */
-	__u32 lcd_last_data;    /* per-op data (disposition for open &c.) */
-	/* for MDS_CLOSE requests */
-	__u64 lcd_last_close_transno; /* last completed transaction ID */
-	__u64 lcd_last_close_xid;     /* xid for the last transaction */
-	__u32 lcd_last_close_result;  /* result from last RPC */
-	__u32 lcd_last_close_data;    /* per-op data */
-	/* VBR: last versions */
-	__u64 lcd_pre_versions[4];
-	__u32 lcd_last_epoch;
-	/** orphans handling for delayed export rely on that */
-	__u32 lcd_first_epoch;
-	__u8  lcd_padding[LR_CLIENT_SIZE - 128];
-};
-
-/* bug20354: the lcd_uuid for export of clients may be wrong */
-static inline void check_lcd(char *obd_name, int index,
-			     struct lsd_client_data *lcd)
-{
-	int length = sizeof(lcd->lcd_uuid);
-
-	if (strnlen((char *)lcd->lcd_uuid, length) == length) {
-		lcd->lcd_uuid[length - 1] = '\0';
-
-		LCONSOLE_ERROR("the client UUID (%s) on %s for exports stored in last_rcvd(index = %d) is bad!\n",
-			       lcd->lcd_uuid, obd_name, index);
-	}
-}
-
-/* last_rcvd handling */
-static inline void lsd_le_to_cpu(struct lr_server_data *buf,
-				 struct lr_server_data *lsd)
-{
-	int i;
-
-	memcpy(lsd->lsd_uuid, buf->lsd_uuid, sizeof(lsd->lsd_uuid));
-	lsd->lsd_last_transno     = le64_to_cpu(buf->lsd_last_transno);
-	lsd->lsd_compat14	 = le64_to_cpu(buf->lsd_compat14);
-	lsd->lsd_mount_count      = le64_to_cpu(buf->lsd_mount_count);
-	lsd->lsd_feature_compat   = le32_to_cpu(buf->lsd_feature_compat);
-	lsd->lsd_feature_rocompat = le32_to_cpu(buf->lsd_feature_rocompat);
-	lsd->lsd_feature_incompat = le32_to_cpu(buf->lsd_feature_incompat);
-	lsd->lsd_server_size      = le32_to_cpu(buf->lsd_server_size);
-	lsd->lsd_client_start     = le32_to_cpu(buf->lsd_client_start);
-	lsd->lsd_client_size      = le16_to_cpu(buf->lsd_client_size);
-	lsd->lsd_subdir_count     = le16_to_cpu(buf->lsd_subdir_count);
-	lsd->lsd_catalog_oid      = le64_to_cpu(buf->lsd_catalog_oid);
-	lsd->lsd_catalog_ogen     = le32_to_cpu(buf->lsd_catalog_ogen);
-	memcpy(lsd->lsd_peeruuid, buf->lsd_peeruuid, sizeof(lsd->lsd_peeruuid));
-	lsd->lsd_osd_index	= le32_to_cpu(buf->lsd_osd_index);
-	lsd->lsd_padding1	= le32_to_cpu(buf->lsd_padding1);
-	lsd->lsd_start_epoch      = le32_to_cpu(buf->lsd_start_epoch);
-	for (i = 0; i < LR_EXPIRE_INTERVALS; i++)
-		lsd->lsd_trans_table[i] = le64_to_cpu(buf->lsd_trans_table[i]);
-	lsd->lsd_trans_table_time = le32_to_cpu(buf->lsd_trans_table_time);
-	lsd->lsd_expire_intervals = le32_to_cpu(buf->lsd_expire_intervals);
-}
-
-static inline void lsd_cpu_to_le(struct lr_server_data *lsd,
-				 struct lr_server_data *buf)
-{
-	int i;
-
-	memcpy(buf->lsd_uuid, lsd->lsd_uuid, sizeof(buf->lsd_uuid));
-	buf->lsd_last_transno     = cpu_to_le64(lsd->lsd_last_transno);
-	buf->lsd_compat14	 = cpu_to_le64(lsd->lsd_compat14);
-	buf->lsd_mount_count      = cpu_to_le64(lsd->lsd_mount_count);
-	buf->lsd_feature_compat   = cpu_to_le32(lsd->lsd_feature_compat);
-	buf->lsd_feature_rocompat = cpu_to_le32(lsd->lsd_feature_rocompat);
-	buf->lsd_feature_incompat = cpu_to_le32(lsd->lsd_feature_incompat);
-	buf->lsd_server_size      = cpu_to_le32(lsd->lsd_server_size);
-	buf->lsd_client_start     = cpu_to_le32(lsd->lsd_client_start);
-	buf->lsd_client_size      = cpu_to_le16(lsd->lsd_client_size);
-	buf->lsd_subdir_count     = cpu_to_le16(lsd->lsd_subdir_count);
-	buf->lsd_catalog_oid      = cpu_to_le64(lsd->lsd_catalog_oid);
-	buf->lsd_catalog_ogen     = cpu_to_le32(lsd->lsd_catalog_ogen);
-	memcpy(buf->lsd_peeruuid, lsd->lsd_peeruuid, sizeof(buf->lsd_peeruuid));
-	buf->lsd_osd_index	  = cpu_to_le32(lsd->lsd_osd_index);
-	buf->lsd_padding1	  = cpu_to_le32(lsd->lsd_padding1);
-	buf->lsd_start_epoch      = cpu_to_le32(lsd->lsd_start_epoch);
-	for (i = 0; i < LR_EXPIRE_INTERVALS; i++)
-		buf->lsd_trans_table[i] = cpu_to_le64(lsd->lsd_trans_table[i]);
-	buf->lsd_trans_table_time = cpu_to_le32(lsd->lsd_trans_table_time);
-	buf->lsd_expire_intervals = cpu_to_le32(lsd->lsd_expire_intervals);
-}
-
-static inline void lcd_le_to_cpu(struct lsd_client_data *buf,
-				 struct lsd_client_data *lcd)
-{
-	memcpy(lcd->lcd_uuid, buf->lcd_uuid, sizeof (lcd->lcd_uuid));
-	lcd->lcd_last_transno       = le64_to_cpu(buf->lcd_last_transno);
-	lcd->lcd_last_xid	   = le64_to_cpu(buf->lcd_last_xid);
-	lcd->lcd_last_result	= le32_to_cpu(buf->lcd_last_result);
-	lcd->lcd_last_data	  = le32_to_cpu(buf->lcd_last_data);
-	lcd->lcd_last_close_transno = le64_to_cpu(buf->lcd_last_close_transno);
-	lcd->lcd_last_close_xid     = le64_to_cpu(buf->lcd_last_close_xid);
-	lcd->lcd_last_close_result  = le32_to_cpu(buf->lcd_last_close_result);
-	lcd->lcd_last_close_data    = le32_to_cpu(buf->lcd_last_close_data);
-	lcd->lcd_pre_versions[0]    = le64_to_cpu(buf->lcd_pre_versions[0]);
-	lcd->lcd_pre_versions[1]    = le64_to_cpu(buf->lcd_pre_versions[1]);
-	lcd->lcd_pre_versions[2]    = le64_to_cpu(buf->lcd_pre_versions[2]);
-	lcd->lcd_pre_versions[3]    = le64_to_cpu(buf->lcd_pre_versions[3]);
-	lcd->lcd_last_epoch	 = le32_to_cpu(buf->lcd_last_epoch);
-	lcd->lcd_first_epoch	= le32_to_cpu(buf->lcd_first_epoch);
-}
-
-static inline void lcd_cpu_to_le(struct lsd_client_data *lcd,
-				 struct lsd_client_data *buf)
-{
-	memcpy(buf->lcd_uuid, lcd->lcd_uuid, sizeof (lcd->lcd_uuid));
-	buf->lcd_last_transno       = cpu_to_le64(lcd->lcd_last_transno);
-	buf->lcd_last_xid	   = cpu_to_le64(lcd->lcd_last_xid);
-	buf->lcd_last_result	= cpu_to_le32(lcd->lcd_last_result);
-	buf->lcd_last_data	  = cpu_to_le32(lcd->lcd_last_data);
-	buf->lcd_last_close_transno = cpu_to_le64(lcd->lcd_last_close_transno);
-	buf->lcd_last_close_xid     = cpu_to_le64(lcd->lcd_last_close_xid);
-	buf->lcd_last_close_result  = cpu_to_le32(lcd->lcd_last_close_result);
-	buf->lcd_last_close_data    = cpu_to_le32(lcd->lcd_last_close_data);
-	buf->lcd_pre_versions[0]    = cpu_to_le64(lcd->lcd_pre_versions[0]);
-	buf->lcd_pre_versions[1]    = cpu_to_le64(lcd->lcd_pre_versions[1]);
-	buf->lcd_pre_versions[2]    = cpu_to_le64(lcd->lcd_pre_versions[2]);
-	buf->lcd_pre_versions[3]    = cpu_to_le64(lcd->lcd_pre_versions[3]);
-	buf->lcd_last_epoch	 = cpu_to_le32(lcd->lcd_last_epoch);
-	buf->lcd_first_epoch	= cpu_to_le32(lcd->lcd_first_epoch);
-}
-
-static inline __u64 lcd_last_transno(struct lsd_client_data *lcd)
-{
-	return (lcd->lcd_last_transno > lcd->lcd_last_close_transno ?
-		lcd->lcd_last_transno : lcd->lcd_last_close_transno);
-}
-
-static inline __u64 lcd_last_xid(struct lsd_client_data *lcd)
-{
-	return (lcd->lcd_last_xid > lcd->lcd_last_close_xid ?
-		lcd->lcd_last_xid : lcd->lcd_last_close_xid);
-}
-
 /****************** superblock additional info *********************/
 
 struct ll_sb_info;
-- 
2.1.0
