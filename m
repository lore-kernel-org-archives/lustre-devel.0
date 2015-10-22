From: kbuild test robot <lkp@intel.com>
Date: Fri, 23 Oct 2015 00:36:55 +0800
Subject: [lustre-devel] [RFC PATCH] locks: posix_lock_inode_wait() can be
	static
In-Reply-To: <ded792d8fdcba562a1c74fd14fefcb387debc4b1.1445524157.git.bcodding@redhat.com>
References: <201510230020.vZvDxsE7%fengguang.wu@intel.com>
Message-ID: <20151022163655.GA111096@roam>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 locks.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index daf4664..0d2b326 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1173,7 +1173,7 @@ EXPORT_SYMBOL(posix_lock_file);
  *
  * Apply a POSIX style lock request to an inode.
  */
-int posix_lock_inode_wait(struct inode *inode, struct file_lock *fl)
+static int posix_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 {
 	int error;
 	might_sleep ();
@@ -1860,7 +1860,7 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
  *
  * Apply a FLOCK style lock request to an inode.
  */
-int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl)
+static int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 {
 	int error;
 	might_sleep();
