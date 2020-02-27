From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:31 -0500
Subject: [lustre-devel] [PATCH 043/622] lustre: checksum: enable/disable
 checksum correctly
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-44-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Emoly Liu <emoly@whamcloud.com>

There are three ways to set checksum support in Lustre. Their
order during client mount is:
- 1. configure --enable/disable-checksum, this(ENABLE_CHECKSUM)
  only affects the default mount option and is set in function
  client_obd_setup().
- 2. lctl set_param -P osc.*.checksums=0/1, when processing llog,
  this value will be set by osc_checksum_seq_write().
- 3. mount option checksum/nochecksum, this will be checked in
  ll_options() and be set in client_common_fill_super()->
  obd_set_info_async().

This patch fixes one issue in 3. That is if mount option
"-o checksum/nochecksum" is specified, checksum will be changed
accordingly, no matter what is set by "set_param -P" or the
default option; and if no mount option is specified, the value
set by "set_param -P" will be kept. Also, test_77k is added to
sanity.sh to verify this patch.

What's more, a minor initialization issue of cl_supp_cksum_types
is fixed. cl_supp_cksum_types should be always initialized no
matter checksum is enabled or not.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10906
Lustre-commit: e9b13cd1daf9 ("LU-10906 checksum: enable/disable checksum correctly")
Signed-off-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32095
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lib.c        |  5 +++--
 fs/lustre/llite/llite_internal.h |  3 ++-
 fs/lustre/llite/llite_lib.c      | 23 ++++++++++++++---------
 3 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 7bc1d10..2c0fad3 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -355,6 +355,8 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 
 	init_waitqueue_head(&cli->cl_destroy_waitq);
 	atomic_set(&cli->cl_destroy_in_flight, 0);
+
+	cli->cl_supp_cksum_types = OBD_CKSUM_CRC32;
 	/* Turn on checksumming by default. */
 	cli->cl_checksum = 1;
 	/*
@@ -362,8 +364,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	 * Set cl_chksum* to CRC32 for now to avoid returning screwed info
 	 * through procfs.
 	 */
-	cli->cl_cksum_type = OBD_CKSUM_CRC32;
-	cli->cl_supp_cksum_types = OBD_CKSUM_CRC32;
+	cli->cl_cksum_type = cli->cl_supp_cksum_types;
 	atomic_set(&cli->cl_resends, OSC_DEFAULT_RESENDS);
 
 	/*
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index d0a703d..6bdbf28 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -479,7 +479,8 @@ struct ll_sb_info {
 	unsigned int		  ll_umounting:1,
 				  ll_xattr_cache_enabled:1,
 				ll_xattr_cache_set:1, /* already set to 0/1 */
-				  ll_client_common_fill_super_succeeded:1;
+				  ll_client_common_fill_super_succeeded:1,
+				  ll_checksum_set:1;
 
 	struct lustre_client_ocd  ll_lco;
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index e2c7a4d..eb29064 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -560,13 +560,15 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	}
 
 	checksum = sbi->ll_flags & LL_SBI_CHECKSUM;
-	err = obd_set_info_async(NULL, sbi->ll_dt_exp, sizeof(KEY_CHECKSUM),
-				 KEY_CHECKSUM, sizeof(checksum), &checksum,
-				 NULL);
-	if (err) {
-		CERROR("%s: Set checksum failed: rc = %d\n",
-		       sbi->ll_dt_exp->exp_obd->obd_name, err);
-		goto out_root;
+	if (sbi->ll_checksum_set) {
+		err = obd_set_info_async(NULL, sbi->ll_dt_exp,
+					 sizeof(KEY_CHECKSUM), KEY_CHECKSUM,
+					 sizeof(checksum), &checksum, NULL);
+		if (err) {
+			CERROR("%s: Set checksum failed: rc = %d\n",
+			       sbi->ll_dt_exp->exp_obd->obd_name, err);
+			goto out_root;
+		}
 	}
 	cl_sb_init(sb);
 
@@ -763,10 +765,11 @@ static inline int ll_set_opt(const char *opt, char *data, int fl)
 }
 
 /* non-client-specific mount options are parsed in lmd_parse */
-static int ll_options(char *options, int *flags)
+static int ll_options(char *options, struct ll_sb_info *sbi)
 {
 	int tmp;
 	char *s1 = options, *s2;
+	int *flags = &sbi->ll_flags;
 
 	if (!options)
 		return 0;
@@ -832,11 +835,13 @@ static int ll_options(char *options, int *flags)
 		tmp = ll_set_opt("checksum", s1, LL_SBI_CHECKSUM);
 		if (tmp) {
 			*flags |= tmp;
+			sbi->ll_checksum_set = 1;
 			goto next;
 		}
 		tmp = ll_set_opt("nochecksum", s1, LL_SBI_CHECKSUM);
 		if (tmp) {
 			*flags &= ~tmp;
+			sbi->ll_checksum_set = 1;
 			goto next;
 		}
 		tmp = ll_set_opt("lruresize", s1, LL_SBI_LRU_RESIZE);
@@ -971,7 +976,7 @@ int ll_fill_super(struct super_block *sb)
 		goto out_free;
 	}
 
-	err = ll_options(lsi->lsi_lmd->lmd_opts, &sbi->ll_flags);
+	err = ll_options(lsi->lsi_lmd->lmd_opts, sbi);
 	if (err)
 		goto out_free;
 
-- 
1.8.3.1
