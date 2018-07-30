From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:49:32 +1000
Subject: [lustre-devel] [PATCH 5/7] lustre/libcfs: discard
 cfs_trace_allocate_string_buffer()
In-Reply-To: <153292249340.26496.13985174182824912332.stgit@noble>
References: <153292249340.26496.13985174182824912332.stgit@noble>
Message-ID: <153292257295.26496.1353870060207416213.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

cfs_trace_allocate_string_buffer() is a simple wrapper
around kzalloc() that adds little value.  The code is
clearer if we perform the test and the allocation
directly where needed.

Also change the test from '>' to '>=' to ensure we
never try to allocate more than 2 pages, as that seems
to be the intent.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/module.c    |    6 +++--
 drivers/staging/lustre/lnet/libcfs/tracefile.c |   28 +++++++++---------------
 drivers/staging/lustre/lnet/libcfs/tracefile.h |    1 -
 3 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 5d2be941777e..1de83b1997c6 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -305,9 +305,9 @@ static int proc_dobitmasks(struct ctl_table *table, int write,
 	int is_subsys = (mask == &libcfs_subsystem_debug) ? 1 : 0;
 	int is_printk = (mask == &libcfs_printk) ? 1 : 0;
 
-	rc = cfs_trace_allocate_string_buffer(&tmpstr, tmpstrlen);
-	if (rc < 0)
-		return rc;
+	tmpstr = kzalloc(tmpstrlen, GFP_KERNEL);
+	if (!tmpstr)
+		return -ENOMEM;
 
 	if (!write) {
 		libcfs_debug_mask2str(tmpstr, tmpstrlen, *mask, is_subsys);
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 40048165fc16..b273107b3815 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -963,26 +963,16 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 }
 EXPORT_SYMBOL(cfs_trace_copyout_string);
 
-int cfs_trace_allocate_string_buffer(char **str, int nob)
-{
-	if (nob > 2 * PAGE_SIZE)	    /* string must be "sensible" */
-		return -EINVAL;
-
-	*str = kmalloc(nob, GFP_KERNEL | __GFP_ZERO);
-	if (!*str)
-		return -ENOMEM;
-
-	return 0;
-}
-
 int cfs_trace_dump_debug_buffer_usrstr(void __user *usr_str, int usr_str_nob)
 {
 	char *str;
 	int rc;
 
-	rc = cfs_trace_allocate_string_buffer(&str, usr_str_nob + 1);
-	if (rc)
-		return rc;
+	if (usr_str_nob >= 2 * PAGE_SIZE)
+		return -EINVAL;
+	str = kzalloc(usr_str_nob + 1, GFP_KERNEL);
+	if (!str)
+		return -ENOMEM;
 
 	rc = cfs_trace_copyin_string(str, usr_str_nob + 1,
 				     usr_str, usr_str_nob);
@@ -1044,9 +1034,11 @@ int cfs_trace_daemon_command_usrstr(void __user *usr_str, int usr_str_nob)
 	char *str;
 	int rc;
 
-	rc = cfs_trace_allocate_string_buffer(&str, usr_str_nob + 1);
-	if (rc)
-		return rc;
+	if (usr_str_nob >= 2 * PAGE_SIZE)
+		return -EINVAL;
+	str = kzalloc(usr_str_nob + 1, GFP_KERNEL);
+	if (!str)
+		return -ENOMEM;
 
 	rc = cfs_trace_copyin_string(str, usr_str_nob + 1,
 				     usr_str, usr_str_nob);
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index 82f090fd8dfa..2134549bb3d7 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -63,7 +63,6 @@ int cfs_trace_copyin_string(char *knl_buffer, int knl_buffer_nob,
 			    const char __user *usr_buffer, int usr_buffer_nob);
 int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 			     const char *knl_str, char *append);
-int cfs_trace_allocate_string_buffer(char **str, int nob);
 int cfs_trace_dump_debug_buffer_usrstr(void __user *usr_str, int usr_str_nob);
 int cfs_trace_daemon_command(char *str);
 int cfs_trace_daemon_command_usrstr(void __user *usr_str, int usr_str_nob);
