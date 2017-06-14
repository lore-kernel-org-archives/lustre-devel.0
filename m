From: James Simmons <jsimmons@infradead.org>
Date: Wed, 14 Jun 2017 11:01:21 -0400
Subject: [lustre-devel] [PATCH 6/6] staging: lustre: lustre: fix all braces
	issues reported by checkpatch
In-Reply-To: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1497452481-31124-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Cleanup all braces that was reported by checkpatch. The only
issue not fixed up is in mdc_lock.c. Removing the braces in
the case of mdc_lock.c will break the build.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fld/fld_cache.c  | 3 ++-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c | 9 +++++----
 drivers/staging/lustre/lustre/llite/vvp_dev.c  | 5 +++--
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index b852fed..adaa094 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -348,9 +348,10 @@ static void fld_cache_overlap_handle(struct fld_cache *cache,
 
 		f_curr->fce_range.lsr_end = new_start;
 		fld_cache_entry_add(cache, f_new, &f_curr->fce_list);
-	} else
+	} else {
 		CERROR("NEW range =" DRANGE " curr = " DRANGE "\n",
 		       PRANGE(range), PRANGE(&f_curr->fce_range));
+	}
 }
 
 struct fld_cache_entry
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 8599134..f47343a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1029,11 +1029,11 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
 	if (work_list && lock->l_completion_ast)
 		ldlm_add_ast_work_item(lock, NULL, work_list);
 
-	if (res->lr_type == LDLM_PLAIN || res->lr_type == LDLM_IBITS)
+	if (res->lr_type == LDLM_PLAIN || res->lr_type == LDLM_IBITS) {
 		ldlm_grant_lock_with_skiplist(lock);
-	else if (res->lr_type == LDLM_EXTENT)
+	} else if (res->lr_type == LDLM_EXTENT) {
 		ldlm_extent_add_lock(res, lock);
-	else if (res->lr_type == LDLM_FLOCK) {
+	} else if (res->lr_type == LDLM_FLOCK) {
 		/*
 		 * We should not add locks to granted list in the following
 		 * cases:
@@ -1046,8 +1046,9 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
 		    ldlm_is_test_lock(lock) || ldlm_is_flock_deadlock(lock))
 			return;
 		ldlm_resource_add_lock(res, &res->lr_granted, lock);
-	} else
+	} else {
 		LBUG();
+	}
 
 	ldlm_pool_add(&ldlm_res_to_ns(res)->ns_pool, lock);
 }
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 8e45672..2b60699 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -591,9 +591,10 @@ static void *vvp_pgcache_start(struct seq_file *f, loff_t *pos)
 	env = cl_env_get(&refcheck);
 	if (!IS_ERR(env)) {
 		sbi = f->private;
-		if (sbi->ll_site->ls_obj_hash->hs_cur_bits > 64 - PGC_OBJ_SHIFT)
+		if (sbi->ll_site->ls_obj_hash->hs_cur_bits >
+		    64 - PGC_OBJ_SHIFT) {
 			pos = ERR_PTR(-EFBIG);
-		else {
+		} else {
 			*pos = vvp_pgcache_find(env, &sbi->ll_cl->cd_lu_dev,
 						*pos);
 			if (*pos == ~0ULL)
-- 
1.8.3.1
