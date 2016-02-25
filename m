From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:42 -0500
Subject: [lustre-devel] [PATCH v2 59/84] staging/lustre: Remove unused
	members of struct ll_sb_info
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-60-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

ll_orphan_dentry_list and ll_conn_chain are not used
and could be removed.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/llite_internal.h | 2 --
 drivers/staging/lustre/lustre/llite/llite_lib.c      | 4 ----
 2 files changed, 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 12fdca9..f6921ff 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -478,10 +478,8 @@ struct ll_sb_info {
 	int		       ll_flags;
 	unsigned int		  ll_umounting:1,
 				  ll_xattr_cache_enabled:1;
-	struct list_head		ll_conn_chain; /* per-conn chain of SBs */
 	struct lustre_client_ocd  ll_lco;
 
-	struct list_head		ll_orphan_dentry_list; /*please don't ask -p*/
 	struct ll_close_queue    *ll_lcq;
 
 	struct lprocfs_stats     *ll_stats; /* lprocfs stats counter */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index d03f884..9ae1cc8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -102,8 +102,6 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
 	sbi->ll_ra_info.ra_max_pages = sbi->ll_ra_info.ra_max_pages_per_file;
 	sbi->ll_ra_info.ra_max_read_ahead_whole_pages =
 					   SBI_DEFAULT_READAHEAD_WHOLE_MAX;
-	INIT_LIST_HEAD(&sbi->ll_conn_chain);
-	INIT_LIST_HEAD(&sbi->ll_orphan_dentry_list);
 
 	ll_generate_random_uuid(uuid);
 	class_uuid_unparse(uuid, &sbi->ll_sb_uuid);
@@ -626,8 +624,6 @@ static void client_common_put_super(struct super_block *sb)
 
 	cl_sb_fini(sb);
 
-	list_del(&sbi->ll_conn_chain);
-
 	obd_fid_fini(sbi->ll_dt_exp->exp_obd);
 	obd_disconnect(sbi->ll_dt_exp);
 	sbi->ll_dt_exp = NULL;
-- 
2.1.0
