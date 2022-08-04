Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6C966C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:39:49 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyrxw6ZTGz23L2;
	Wed,  3 Aug 2022 18:39:48 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwc4NGGz23Jk
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:40 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id DBF55100B02F;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DADA980795; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:05 -0400
Message-Id: <1659577097-19253-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/32] lnet: libcfs: debugfs file_operation
 should have an owner
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

If debugfs a file is open when unloading the libcfs/lnet module, it
produces a kernel Oops (debugfs file_operations callbacks no longer
exist).

Crash generated with routerstat (/sys/kernel/debug/lnet/stats):
[ 1449.750396] IP: [<ffffffffab24e093>] SyS_lseek+0x83/0x100
[ 1449.750412] PGD 9fa14067 PUD 9fa16067 PMD d4e5d067 PTE 0
[ 1449.750428] Oops: 0000 [#1] SMP
[ 1449.750883]  [<ffffffffab7aaf92>] system_call_fastpath+0x25/0x2a
[ 1449.750897]  [<ffffffffab7aaed5>] ?
system_call_after_swapgs+0xa2/0x13a

This patch adds an owner to debugfs file_operation for libcfs and
lnet_router entries (/sys/kernel/debug/lnet/*).

The following behavior is expected:
$ modprobe lustre
$ routerstat 10 > /dev/null &
$ lustre_rmmod
rmmod: ERROR: Module lnet is in use
Can't read statfile (ENODEV)
[1]+  Exit 1                  routerstat 10 > /dev/null
$ lustre_rmmod

Note that the allocated 'struct file_operations' cannot be freed until
the module_exit() function is called, as files could still be open
until then.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15759
Lustre-commit: b2dfb4457f0f1e56f ("LU-15759 libcfs: debugfs file_operation should have an owner")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/47335
Reviewed-by: Etienne AUJAMES <eaujames@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs.h |  4 +++-
 include/linux/lnet/lib-lnet.h |  1 +
 net/lnet/libcfs/module.c      | 43 ++++++++++++++++++++++++++++++++++++-------
 net/lnet/lnet/module.c        |  1 +
 net/lnet/lnet/router_proc.c   | 10 +++++++++-
 5 files changed, 50 insertions(+), 9 deletions(-)

diff --git a/include/linux/libcfs/libcfs.h b/include/linux/libcfs/libcfs.h
index b59ef9b..e29b007 100644
--- a/include/linux/libcfs/libcfs.h
+++ b/include/linux/libcfs/libcfs.h
@@ -57,8 +57,10 @@ static inline int notifier_from_ioctl_errno(int err)
 
 extern struct workqueue_struct *cfs_rehash_wq;
 
-void lnet_insert_debugfs(struct ctl_table *table);
+void lnet_insert_debugfs(struct ctl_table *table, struct module *mod,
+			 void **statep);
 void lnet_remove_debugfs(struct ctl_table *table);
+void lnet_debugfs_fini(void **statep);
 
 int debugfs_doint(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos);
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 5a83190..57c8dc2 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -569,6 +569,7 @@ unsigned int lnet_nid_cpt_hash(struct lnet_nid *nid,
 
 int lnet_lib_init(void);
 void lnet_lib_exit(void);
+void lnet_router_exit(void);
 
 void lnet_mt_event_handler(struct lnet_event *event);
 
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index a249bdd..a126683 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -746,19 +746,23 @@ static ssize_t lnet_debugfs_write(struct file *filp, const char __user *buf,
 	.llseek		= default_llseek,
 };
 
-static const struct file_operations *lnet_debugfs_fops_select(umode_t mode)
+static const struct file_operations *
+lnet_debugfs_fops_select(umode_t mode, const struct file_operations state[3])
 {
 	if (!(mode & 0222))
-		return &lnet_debugfs_file_operations_ro;
+		return &state[0];
 
 	if (!(mode & 0444))
-		return &lnet_debugfs_file_operations_wo;
+		return &state[1];
 
-	return &lnet_debugfs_file_operations_rw;
+	return &state[2];
 }
 
-void lnet_insert_debugfs(struct ctl_table *table)
+void lnet_insert_debugfs(struct ctl_table *table, struct module *mod,
+			 void **statep)
 {
+	struct file_operations *state = *statep;
+
 	if (!lnet_debugfs_root)
 		lnet_debugfs_root = debugfs_create_dir("lnet", NULL);
 
@@ -766,6 +770,19 @@ void lnet_insert_debugfs(struct ctl_table *table)
 	if (IS_ERR_OR_NULL(lnet_debugfs_root))
 		return;
 
+	if (!state) {
+		state = kmalloc(3 * sizeof(*state), GFP_KERNEL);
+		if (!state)
+			return;
+		state[0] = lnet_debugfs_file_operations_ro;
+		state[0].owner = mod;
+		state[1] = lnet_debugfs_file_operations_wo;
+		state[1].owner = mod;
+		state[2] = lnet_debugfs_file_operations_rw;
+		state[2].owner = mod;
+		*statep = state;
+	}
+
 	/*
 	 * We don't save the dentry returned because we don't call
 	 * debugfs_remove() but rather remove_recursive()
@@ -773,10 +790,18 @@ void lnet_insert_debugfs(struct ctl_table *table)
 	for (; table && table->procname; table++)
 		debugfs_create_file(table->procname, table->mode,
 				    lnet_debugfs_root, table,
-				    lnet_debugfs_fops_select(table->mode));
+				    lnet_debugfs_fops_select(table->mode,
+							     (const struct file_operations *)state));
 }
 EXPORT_SYMBOL_GPL(lnet_insert_debugfs);
 
+void lnet_debugfs_fini(void **state)
+{
+	kfree(*state);
+	*state = NULL;
+}
+EXPORT_SYMBOL_GPL(lnet_debugfs_fini);
+
 static void lnet_insert_debugfs_links(
 	const struct lnet_debugfs_symlink_def *symlinks)
 {
@@ -801,6 +826,8 @@ void lnet_remove_debugfs(struct ctl_table *table)
 static DEFINE_MUTEX(libcfs_startup);
 static int libcfs_active;
 
+static void *debugfs_state;
+
 int libcfs_setup(void)
 {
 	int rc = -EINVAL;
@@ -855,7 +882,7 @@ static int libcfs_init(void)
 {
 	int rc;
 
-	lnet_insert_debugfs(lnet_table);
+	lnet_insert_debugfs(lnet_table, THIS_MODULE, &debugfs_state);
 	if (!IS_ERR_OR_NULL(lnet_debugfs_root))
 		lnet_insert_debugfs_links(lnet_debugfs_symlinks);
 
@@ -875,6 +902,8 @@ static void libcfs_exit(void)
 	debugfs_remove_recursive(lnet_debugfs_root);
 	lnet_debugfs_root = NULL;
 
+	lnet_debugfs_fini(&debugfs_state);
+
 	if (cfs_rehash_wq)
 		destroy_workqueue(cfs_rehash_wq);
 
diff --git a/net/lnet/lnet/module.c b/net/lnet/lnet/module.c
index aba9589..9d7b39a 100644
--- a/net/lnet/lnet/module.c
+++ b/net/lnet/lnet/module.c
@@ -271,6 +271,7 @@ static void __exit lnet_exit(void)
 						&lnet_ioctl_handler);
 	LASSERT(!rc);
 
+	lnet_router_exit();
 	lnet_lib_exit();
 }
 
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index f231da1..689670a 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -888,12 +888,20 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
 	}
 };
 
+static void *debugfs_state;
+
 void lnet_router_debugfs_init(void)
 {
-	lnet_insert_debugfs(lnet_table);
+	lnet_insert_debugfs(lnet_table, THIS_MODULE,
+			    &debugfs_state);
 }
 
 void lnet_router_debugfs_fini(void)
 {
 	lnet_remove_debugfs(lnet_table);
 }
+
+void lnet_router_exit(void)
+{
+	lnet_debugfs_fini(&debugfs_state);
+}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
