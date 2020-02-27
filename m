From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:28 -0500
Subject: [lustre-devel] [PATCH 280/622] lustre: obd: replace class_uuid with
 linux kernel version.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-281-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We can replace the lustre custom class_uuid_t with the linux
kernels uuid handling.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11803
Lustre-commit: 604c266a175b ("LU-11803 obd: replace class_uuid with linux kernel version.")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/33916
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h  | 10 ----------
 fs/lustre/llite/llite_lib.c    | 23 +++++++++++++----------
 fs/lustre/obdclass/obd_mount.c |  8 +++++---
 3 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 6cddc4f..a142d6e 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1672,13 +1672,6 @@ struct lwp_register_item {
 /* obd_mount.c */
 int lustre_check_exclusion(struct super_block *sb, char *svname);
 
-typedef u8 class_uuid_t[16];
-
-static inline void class_uuid_unparse(class_uuid_t uu, struct obd_uuid *out)
-{
-	sprintf(out->uuid, "%pU", uu);
-}
-
 /* lustre_peer.c    */
 int lustre_uuid_to_peer(const char *uuid, lnet_nid_t *peer_nid, int index);
 int class_add_uuid(const char *uuid, u64 nid);
@@ -1689,9 +1682,6 @@ static inline void class_uuid_unparse(class_uuid_t uu, struct obd_uuid *out)
 extern char obd_jobid_name[];
 int class_procfs_init(void);
 int class_procfs_clean(void);
-/* prng.c */
-#define ll_generate_random_uuid(uuid_out) \
-	get_random_bytes(uuid_out, sizeof(class_uuid_t))
 
 /* statfs_pack.c */
 struct kstatfs;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 21825251..99cedcf 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -38,9 +38,11 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include <linux/module.h>
+#include <linux/random.h>
 #include <linux/statfs.h>
 #include <linux/types.h>
 #include <linux/mm.h>
+#include <linux/uuid.h>
 #include <linux/random.h>
 #include <linux/security.h>
 #include <linux/fs_struct.h>
@@ -69,7 +71,6 @@ static struct ll_sb_info *ll_init_sbi(void)
 	unsigned long pages;
 	unsigned long lru_page_max;
 	struct sysinfo si;
-	class_uuid_t uuid;
 	int i;
 
 	sbi = kzalloc(sizeof(*sbi), GFP_NOFS);
@@ -97,11 +98,6 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_ra_info.ra_max_pages = sbi->ll_ra_info.ra_max_pages_per_file;
 	sbi->ll_ra_info.ra_max_read_ahead_whole_pages = -1;
 
-	ll_generate_random_uuid(uuid);
-	sprintf(sbi->ll_sb_uuid.uuid, "%pU", uuid);
-
-	CDEBUG(D_CONFIG, "generated uuid: %s\n", sbi->ll_sb_uuid.uuid);
-
 	sbi->ll_flags |= LL_SBI_VERBOSE;
 	sbi->ll_flags |= LL_SBI_CHECKSUM;
 	sbi->ll_flags |= LL_SBI_FLOCK;
@@ -965,6 +961,7 @@ int ll_fill_super(struct super_block *sb)
 	char *profilenm = get_profile_name(sb);
 	struct config_llog_instance *cfg;
 	char name[MAX_OBD_NAME];
+	uuid_t uuid;
 	char *ptr;
 	int len;
 	int err;
@@ -991,13 +988,15 @@ int ll_fill_super(struct super_block *sb)
 	if (err)
 		goto out_free;
 
-	err = super_setup_bdi_name(sb, "lustre-%p", sb);
-	if (err)
-		goto out_free;
-
 	/* kernel >= 2.6.38 store dentry operations in sb->s_d_op. */
 	sb->s_d_op = &ll_d_ops;
 
+	/* UUID handling */
+	generate_random_uuid(uuid.b);
+	snprintf(sbi->ll_sb_uuid.uuid, UUID_SIZE, "%pU", uuid.b);
+
+	CDEBUG(D_CONFIG, "llite sb uuid: %s\n", sbi->ll_sb_uuid.uuid);
+
 	/* Get fsname */
 	len = strlen(lsi->lsi_lmd->lmd_profile);
 	ptr = strrchr(lsi->lsi_lmd->lmd_profile, '-');
@@ -1021,6 +1020,10 @@ int ll_fill_super(struct super_block *sb)
 	snprintf(name, sizeof(name), "%.*s-%px", len,
 		 lsi->lsi_lmd->lmd_profile, sb);
 
+	err = super_setup_bdi_name(sb, "%s", name);
+	if (err)
+		goto out_free;
+
 	/* Call ll_debugsfs_register_super() before lustre_process_log()
 	 * so that "llite.*.*" params can be processed correctly.
 	 */
diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index 6c68bc7..31f2f5b 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -44,6 +44,8 @@
 #include <linux/random.h>
 #include <obd.h>
 #include <obd_class.h>
+#include <linux/random.h>
+#include <linux/uuid.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <lustre_log.h>
 #include <lustre_disk.h>
@@ -216,7 +218,7 @@ int lustre_start_mgc(struct super_block *sb)
 	struct obd_device *obd;
 	struct obd_export *exp;
 	struct obd_uuid *uuid = NULL;
-	class_uuid_t uuidc;
+	uuid_t uuidc;
 	lnet_nid_t nid;
 	char nidstr[LNET_NIDSTR_SIZE];
 	char *mgcname = NULL, *niduuid = NULL, *mgssec = NULL;
@@ -336,8 +338,8 @@ int lustre_start_mgc(struct super_block *sb)
 		goto out_free;
 	}
 
-	ll_generate_random_uuid(uuidc);
-	sprintf(uuid->uuid, "%pU", uuidc);
+	generate_random_uuid(uuidc.b);
+	snprintf(uuid->uuid, UUID_SIZE, "%pU", uuidc.b);
 
 	/* Start the MGC */
 	rc = lustre_start_simple(mgcname, LUSTRE_MGC_NAME,
-- 
1.8.3.1
