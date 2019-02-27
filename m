From: NeilBrown <neilb@suse.com>
Date: Wed, 27 Feb 2019 11:41:49 +1100
Subject: [lustre-devel] [PATCH 21/37] lustre: remove several
 MAX_STRING_SIZE defines.
In-Reply-To: <alpine.LFD.2.21.1902241855300.1485@casper.infradead.org>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494593.24125.427229089746560574.stgit@noble.brown>
 <alpine.LFD.2.21.1902241855300.1485@casper.infradead.org>
Message-ID: <87mumit642.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Feb 24 2019, James Simmons wrote:

>> Some of these are unused.
>> One is used in a minimal way where it is easier to use
>> an explicit number.
>
> While I dislike mystery meat type defines like MAX_STRING_SIZE I also 
> don't like using raw numbers. In the past using raw numbers has causes
> problems when requirements changed that were not easy to track down
> why the new bug appeared. Mind you the same problem exist for constants 
> like MAX_STRING_SIZE which provides no real meaning to why the magically 
> number 128 is used. 
>  
> This number seems to be a limiting factor in the naming of sysfs directory
> and file naming. I kind of see why this number has no meaning. So such
> a number belongs in one place, lprocfs_status.h. Now sysfs attributes
> can have any naming style they want, within reason :-) As for directories
> that is limited by MAX_OBD_NAME. What do you know MAX_OBD_NAME is equal
> too MAX_STRING_SIZE (hint hint) :-) 

I've changed the 128 to MAX_OBD_NAME - seems to make sense.

I've also added the patch below.

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.com>
Subject: [PATCH] lustre: ldlm: discard varname in ldlm_pool.

This allocated buffer serves no purpose.
A constant string is copied into it, it is passed to some
function which copies it out again, then the buffer is freed.
Instead, we can pass the constant string to that function.
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  2 --
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 16 ++++------------
 2 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index d8dcf8a73e4b..c907d880274d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -31,8 +31,6 @@
  * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
-#define MAX_STRING_SIZE 128
-
 extern int ldlm_srv_namespace_nr;
 extern int ldlm_cli_namespace_nr;
 extern struct mutex ldlm_srv_namespace_lock;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 5b23767faecf..adc3f3737daa 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -505,7 +505,7 @@ LUSTRE_RW_ATTR(lock_volume_factor);
 
 #define LDLM_POOL_ADD_VAR(name, var, ops)			\
 	do {							\
-		snprintf(var_name, MAX_STRING_SIZE, #name);	\
+		pool_vars[0].name = #name;			\
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
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190227/6294d854/attachment.sig>
