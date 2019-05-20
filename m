From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:56 -0400
Subject: [lustre-devel] [PATCH v2 14/29] lustre: ldlm: discard varname in
 ldlm_pool.
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This allocated buffer serves no purpose.
A constant string is copied into it, it is passed to some
function which copies it out again, then the buffer is freed.
Instead, we can pass the constant string to that function.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/ldlm/ldlm_internal.h |  2 --
 fs/lustre/ldlm/ldlm_pool.c     | 18 +++++-------------
 2 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index d8dcf8a..c907d88 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -31,8 +31,6 @@
  * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
-#define MAX_STRING_SIZE 128
-
 extern int ldlm_srv_namespace_nr;
 extern int ldlm_cli_namespace_nr;
 extern struct mutex ldlm_srv_namespace_lock;
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 1f81795..a984b5d 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -503,9 +503,9 @@ static ssize_t grant_speed_show(struct kobject *kobj, struct attribute *attr,
 LDLM_POOL_SYSFS_WRITER_NOLOCK_STORE(lock_volume_factor, atomic);
 LUSTRE_RW_ATTR(lock_volume_factor);
 
-#define LDLM_POOL_ADD_VAR(name, var, ops)			\
+#define LDLM_POOL_ADD_VAR(_name, var, ops)			\
 	do {							\
-		snprintf(var_name, MAX_STRING_SIZE, #name);	\
+		pool_vars[0].name = #_name;			\
 		pool_vars[0].data = var;			\
 		pool_vars[0].fops = ops;			\
 		ldebugfs_add_vars(pl->pl_debugfs_entry, pool_vars, NULL);\
@@ -557,25 +557,18 @@ static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
 						 ns_pool);
 	struct dentry *debugfs_ns_parent;
 	struct lprocfs_vars pool_vars[2];
-	char *var_name = NULL;
 	int rc = 0;
 
-	var_name = kzalloc(MAX_STRING_SIZE + 1, GFP_NOFS);
-	if (!var_name)
-		return -ENOMEM;
-
 	debugfs_ns_parent = ns->ns_debugfs_entry;
 	if (IS_ERR_OR_NULL(debugfs_ns_parent)) {
 		CERROR("%s: debugfs entry is not initialized\n",
 		       ldlm_ns_name(ns));
 		rc = -EINVAL;
-		goto out_free_name;
+		goto out;
 	}
 	pl->pl_debugfs_entry = debugfs_create_dir("pool", debugfs_ns_parent);
 
-	var_name[MAX_STRING_SIZE] = '\0';
 	memset(pool_vars, 0, sizeof(pool_vars));
-	pool_vars[0].name = var_name;
 
 	LDLM_POOL_ADD_VAR(state, pl, &lprocfs_pool_state_fops);
 
@@ -583,7 +576,7 @@ static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
 					   LDLM_POOL_FIRST_STAT, 0);
 	if (!pl->pl_stats) {
 		rc = -ENOMEM;
-		goto out_free_name;
+		goto out;
 	}
 
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANTED_STAT,
@@ -622,8 +615,7 @@ static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
 	debugfs_create_file("stats", 0644, pl->pl_debugfs_entry, pl->pl_stats,
 			    &lprocfs_stats_seq_fops);
 
-out_free_name:
-	kfree(var_name);
+out:
 	return rc;
 }
 
-- 
1.8.3.1
