From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:33 -0400
Subject: [lustre-devel] [PATCH 134/151] lustre: llite: fix mount error
 handing
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-135-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vladimir Saveliev <c17830@cray.com>

lustre_fill_super() allocates lsi and assumes that on failures lsi
will be freed by server_fill_super() or ll_fill_super().
 - server_fill_super() does not free lsi when lsi_prepare() fails.
 - ll_fill_super() does not free lsi when OBD_ALLOC_PTR(cfg) or
ll_init_sbi() fail.

WC-bug-id: https://jira.whamcloud.com/browse/LU-5991
Cray-bug-id: MRP-2229
Lustre-commit: acabfb9594c9 ("LU-5991 llite: fix mount error handing")
Signed-off-by: Vladimir Saveliev <c17830@cray.com>
Reviewed-on: https://review.whamcloud.com/12959
Reviewed-by: Sergey Cheremencev <c17829@cray.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 758f856..c94bc65 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -939,7 +939,7 @@ int ll_fill_super(struct super_block *sb)
 {
 	struct lustre_profile *lprof = NULL;
 	struct lustre_sb_info *lsi = s2lsi(sb);
-	struct ll_sb_info *sbi;
+	struct ll_sb_info *sbi = NULL;
 	char *dt = NULL, *md = NULL;
 	char *profilenm = get_profile_name(sb);
 	struct config_llog_instance *cfg;
@@ -950,21 +950,20 @@ int ll_fill_super(struct super_block *sb)
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p\n", sb);
 
+	try_module_get(THIS_MODULE);
+
 	cfg = kzalloc(sizeof(*cfg), GFP_NOFS);
 	if (!cfg) {
-		ll_common_put_super(sb);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto out_free;
 	}
-	try_module_get(THIS_MODULE);
 
 	/* client additional sb info */
 	sbi = ll_init_sbi();
 	lsi->lsi_llsbi = sbi;
 	if (!sbi) {
-		module_put(THIS_MODULE);
-		kfree(cfg);
-		ll_common_put_super(sb);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto out_free;
 	}
 
 	err = ll_options(lsi->lsi_lmd->lmd_opts, &sbi->ll_flags);
@@ -1048,12 +1047,12 @@ int ll_fill_super(struct super_block *sb)
 	kfree(dt);
 	if (lprof)
 		class_put_profile(lprof);
+	kfree(cfg);
 	if (err)
 		ll_put_super(sb);
 	else if (sbi->ll_flags & LL_SBI_VERBOSE)
 		LCONSOLE_WARN("Mounted %s\n", profilenm);
 
-	kfree(cfg);
 	return err;
 } /* ll_fill_super */
 
@@ -1073,6 +1072,9 @@ void ll_put_super(struct super_block *sb)
 	int next, force = 1, rc = 0;
 	long ccc_count;
 
+	if (!sbi)
+		goto out_no_sbi;
+
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p - %s\n", sb, profilenm);
 
 	cfg.cfg_instance = sb;
@@ -1125,6 +1127,7 @@ void ll_put_super(struct super_block *sb)
 	ll_free_sbi(sb);
 	lsi->lsi_llsbi = NULL;
 
+out_no_sbi:
 	ll_common_put_super(sb);
 
 	cl_env_cache_purge(~0);
-- 
1.8.3.1
