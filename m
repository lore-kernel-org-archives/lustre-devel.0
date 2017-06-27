From: Benjamin Coddington <bcodding@redhat.com>
Date: Tue, 27 Jun 2017 11:18:08 -0400
Subject: [lustre-devel] [PATCH 2/3] fs/locks: Remove fl_nspid and use
	fs-specific l_pid for remote locks
In-Reply-To: <cover.1498572504.git.bcodding@redhat.com>
References: <cover.1498572504.git.bcodding@redhat.com>
Message-ID: <f05311e041bb4a44b61d4b19e50dadf05ea913a7.1498572504.git.bcodding@redhat.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Steve French <sfrench@samba.org>, Christine Caulfield <ccaulfie@redhat.com>, David Teigland <teigland@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Vitaly Fertman <vitaly_fertman@xyratex.com>, "John L. Hammond" <john.hammond@intel.com>, Andriy Skulysh <andriy.skulysh@seagate.com>, Benjamin Coddington <bcodding@redhat.com>, Emoly Liu <emoly.liu@intel.com>
Cc: devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-kernel@vger.kernel.org, cluster-devel@redhat.com, linux-fsdevel@vger.kernel.org, v9fs-developer@lists.sourceforge.net, ceph-devel@vger.kernel.org, lustre-devel@lists.lustre.org

Since commit c69899a17ca4 "NFSv4: Update of VFS byte range lock must be
atomic with the stateid update", NFSv4 has been inserting locks in rpciod
worker context.  The result is that the file_lock's fl_nspid is the
kworker's pid instead of the original userspace pid.

The fl_nspid is only used to represent the namespaced virtual pid number
when displaying locks or returning from F_GETLK.  There's no reason to set
it for every inserted lock, since we can usually just look it up from
fl_pid.  So, instead of looking up and holding struct pid for every lock,
let's just look up the virtual pid number from fl_pid when it is needed.
That means we can remove fl_nspid entirely.

The translaton and presentation of fl_pid should handle the following four
cases:

1 - F_GETLK on a remote file with a remote lock:
    In this case, the filesystem should determine the l_pid to return here.
    Filesystems should indicate that the fl_pid represents a non-local pid
    value that should not be translated by returning an fl_pid <= 0.

2 - F_GETLK on a local file with a remote lock:
    This should be the l_pid of the lock manager process, and translated.

3 - F_GETLK on a remote file with a local lock, and
4 - F_GETLK on a local file with a local lock:
    These should be the translated l_pid of the local locking process.

Fuse was already doing the correct thing by translating the pid into the
caller's namespace.  With this change we must update fuse to translate to
init's pid namespace, so that the locks API can then translate from init's
pid namespace into the pid namespace of the caller.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/fuse/file.c     |  6 +++---
 fs/locks.c         | 62 ++++++++++++++++++++++++++++++++----------------------
 include/linux/fs.h |  2 +-
 3 files changed, 41 insertions(+), 29 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 3ee4fdc3da9e..7cd692f51d1d 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2101,11 +2101,11 @@ static int convert_fuse_file_lock(struct fuse_conn *fc,
 		fl->fl_end = ffl->end;
 
 		/*
-		 * Convert pid into the caller's pid namespace. If the pid
-		 * does not map into the namespace fl_pid will get set to 0.
+		 * Convert pid into init's pid namespace.  The locks API will
+		 * translate it into the caller's pid namespace.
 		 */
 		rcu_read_lock();
-		fl->fl_pid = pid_vnr(find_pid_ns(ffl->pid, fc->pid_ns));
+		fl->fl_pid = pid_nr_ns(find_pid_ns(ffl->pid, fc->pid_ns), &init_pid_ns);
 		rcu_read_unlock();
 		break;
 
diff --git a/fs/locks.c b/fs/locks.c
index d7daa6c8932f..6d0949880ebd 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -137,6 +137,7 @@
 #define IS_FLOCK(fl)	(fl->fl_flags & FL_FLOCK)
 #define IS_LEASE(fl)	(fl->fl_flags & (FL_LEASE|FL_DELEG|FL_LAYOUT))
 #define IS_OFDLCK(fl)	(fl->fl_flags & FL_OFDLCK)
+#define IS_REMOTELCK(fl)	(fl->fl_pid <= 0)
 
 static inline bool is_remote_lock(struct file *filp)
 {
@@ -733,7 +734,6 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 static void
 locks_insert_lock_ctx(struct file_lock *fl, struct list_head *before)
 {
-	fl->fl_nspid = get_pid(task_tgid(current));
 	list_add_tail(&fl->fl_list, before);
 	locks_insert_global_locks(fl);
 }
@@ -743,10 +743,6 @@ locks_unlink_lock_ctx(struct file_lock *fl)
 {
 	locks_delete_global_locks(fl);
 	list_del_init(&fl->fl_list);
-	if (fl->fl_nspid) {
-		put_pid(fl->fl_nspid);
-		fl->fl_nspid = NULL;
-	}
 	locks_wake_up_blocks(fl);
 }
 
@@ -823,8 +819,6 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
 	list_for_each_entry(cfl, &ctx->flc_posix, fl_list) {
 		if (posix_locks_conflict(fl, cfl)) {
 			locks_copy_conflock(fl, cfl);
-			if (cfl->fl_nspid)
-				fl->fl_pid = pid_vnr(cfl->fl_nspid);
 			goto out;
 		}
 	}
@@ -2048,9 +2042,33 @@ int vfs_test_lock(struct file *filp, struct file_lock *fl)
 }
 EXPORT_SYMBOL_GPL(vfs_test_lock);
 
+/**
+ * locks_translate_pid - translate a file_lock's fl_pid number into a namespace
+ * @fl: The file_lock who's fl_pid should be translated
+ * @ns: The namespace into which the pid should be translated
+ *
+ * Used to tranlate a fl_pid into a namespace virtual pid number
+ */
+static pid_t locks_translate_pid(struct file_lock *fl, struct pid_namespace *ns)
+{
+	pid_t vnr;
+	struct pid *pid;
+
+	if (IS_OFDLCK(fl))
+		return -1;
+	if (IS_REMOTELCK(fl))
+		return fl->fl_pid;
+
+	rcu_read_lock();
+	pid = find_pid_ns(fl->fl_pid, &init_pid_ns);
+	vnr = pid_nr_ns(pid, ns);
+	rcu_read_unlock();
+	return vnr;
+}
+
 static int posix_lock_to_flock(struct flock *flock, struct file_lock *fl)
 {
-	flock->l_pid = IS_OFDLCK(fl) ? -1 : fl->fl_pid;
+	flock->l_pid = locks_translate_pid(fl, task_active_pid_ns(current));
 #if BITS_PER_LONG == 32
 	/*
 	 * Make sure we can represent the posix lock via
@@ -2072,7 +2090,7 @@ static int posix_lock_to_flock(struct flock *flock, struct file_lock *fl)
 #if BITS_PER_LONG == 32
 static void posix_lock_to_flock64(struct flock64 *flock, struct file_lock *fl)
 {
-	flock->l_pid = IS_OFDLCK(fl) ? -1 : fl->fl_pid;
+	flock->l_pid = locks_translate_pid(fl, task_active_pid_ns(current));
 	flock->l_start = fl->fl_start;
 	flock->l_len = fl->fl_end == OFFSET_MAX ? 0 :
 		fl->fl_end - fl->fl_start + 1;
@@ -2584,22 +2602,16 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 {
 	struct inode *inode = NULL;
 	unsigned int fl_pid;
+	struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
 
-	if (fl->fl_nspid) {
-		struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
-
-		/* Don't let fl_pid change based on who is reading the file */
-		fl_pid = pid_nr_ns(fl->fl_nspid, proc_pidns);
-
-		/*
-		 * If there isn't a fl_pid don't display who is waiting on
-		 * the lock if we are called from locks_show, or if we are
-		 * called from __show_fd_info - skip lock entirely
-		 */
-		if (fl_pid == 0)
-			return;
-	} else
-		fl_pid = fl->fl_pid;
+	fl_pid = locks_translate_pid(fl, proc_pidns);
+	/*
+	 * If there isn't a fl_pid don't display who is waiting on
+	 * the lock if we are called from locks_show, or if we are
+	 * called from __show_fd_info - skip lock entirely
+	 */
+	if (fl_pid == 0)
+		return;
 
 	if (fl->fl_file != NULL)
 		inode = locks_inode(fl->fl_file);
@@ -2674,7 +2686,7 @@ static int locks_show(struct seq_file *f, void *v)
 
 	fl = hlist_entry(v, struct file_lock, fl_link);
 
-	if (fl->fl_nspid && !pid_nr_ns(fl->fl_nspid, proc_pidns))
+	if (locks_translate_pid(fl, proc_pidns) == 0)
 		return 0;
 
 	lock_get_status(f, fl, iter->li_pos, "");
diff --git a/include/linux/fs.h b/include/linux/fs.h
index aa4affb38c39..179496a9719d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -908,6 +908,7 @@ static inline struct file *get_file(struct file *f)
 #define FL_UNLOCK_PENDING	512 /* Lease is being broken */
 #define FL_OFDLCK	1024	/* lock is "owned" by struct file */
 #define FL_LAYOUT	2048	/* outstanding pNFS layout */
+#define FL_PID_PRIV	4096	/* F_GETLK should report fl_pid */
 
 #define FL_CLOSE_POSIX (FL_POSIX | FL_CLOSE)
 
@@ -984,7 +985,6 @@ struct file_lock {
 	unsigned char fl_type;
 	unsigned int fl_pid;
 	int fl_link_cpu;		/* what cpu's list is this on? */
-	struct pid *fl_nspid;
 	wait_queue_head_t fl_wait;
 	struct file *fl_file;
 	loff_t fl_start;
-- 
2.9.3
