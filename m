From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:14 -0500
Subject: [lustre-devel] [PATCH 36/56] staging/lustre: Remove server data
	from struct obd_export
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-37-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Despite it's name struct obd_export could exist on the client too
(used for reverse exports), but all the actual server bits
are not needed there, so could be dropped. This is mostly
various target-related stuff.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre_export.h  | 70 ----------------------
 1 file changed, 70 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 86f91ce..30ae096 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -50,62 +50,6 @@
 #include "lustre/lustre_idl.h"
 #include "lustre_dlm.h"
 
-struct mds_client_data;
-struct mdt_client_data;
-struct mds_idmap_table;
-struct mdt_idmap_table;
-
-/**
- * Target-specific export data
- */
-struct tg_export_data {
-	/** Protects led_lcd below */
-	struct mutex		ted_lcd_lock;
-	/** Per-client data for each export */
-	struct lsd_client_data	*ted_lcd;
-	/** Offset of record in last_rcvd file */
-	loff_t			ted_lr_off;
-	/** Client index in last_rcvd file */
-	int			ted_lr_idx;
-};
-
-/**
- * MDT-specific export data
- */
-struct mdt_export_data {
-	struct tg_export_data	med_ted;
-	/** List of all files opened by client on this MDT */
-	struct list_head		med_open_head;
-	spinlock_t		med_open_lock; /* med_open_head, mfd_list */
-	/** Bitmask of all ibit locks this MDT understands */
-	__u64			med_ibits_known;
-	struct mutex		med_idmap_mutex;
-	struct lustre_idmap_table *med_idmap;
-};
-
-struct ec_export_data { /* echo client */
-	struct list_head eced_locks;
-};
-
-/* In-memory access to client data from OST struct */
-/** Filter (oss-side) specific import data */
-struct filter_export_data {
-	struct tg_export_data	fed_ted;
-	spinlock_t		fed_lock;	/**< protects fed_mod_list */
-	long		       fed_dirty;    /* in bytes */
-	long		       fed_grant;    /* in bytes */
-	struct list_head		 fed_mod_list; /* files being modified */
-	int			fed_mod_count;/* items in fed_writing list */
-	long		       fed_pending;  /* bytes just being written */
-	__u32		      fed_group;
-	__u8		       fed_pagesize; /* log2 of client page size */
-};
-
-struct mgs_export_data {
-	struct list_head		med_clients;	/* mgc fs client via this exp */
-	spinlock_t		med_lock;	/* protect med_clients */
-};
-
 enum obd_option {
 	OBD_OPT_FORCE =	 0x0001,
 	OBD_OPT_FAILOVER =      0x0002,
@@ -200,22 +144,8 @@ struct obd_export {
 	/** blocking dlm lock list, protected by exp_bl_list_lock */
 	struct list_head		exp_bl_list;
 	spinlock_t		  exp_bl_list_lock;
-
-	/** Target specific data */
-	union {
-		struct tg_export_data     eu_target_data;
-		struct mdt_export_data    eu_mdt_data;
-		struct filter_export_data eu_filter_data;
-		struct ec_export_data     eu_ec_data;
-		struct mgs_export_data    eu_mgs_data;
-	} u;
 };
 
-#define exp_target_data u.eu_target_data
-#define exp_mdt_data    u.eu_mdt_data
-#define exp_filter_data u.eu_filter_data
-#define exp_ec_data     u.eu_ec_data
-
 static inline __u64 *exp_connect_flags_ptr(struct obd_export *exp)
 {
 	return &exp->exp_connect_data.ocd_connect_flags;
-- 
2.1.0
