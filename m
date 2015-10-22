From: Benjamin Coddington <bcodding@redhat.com>
Date: Thu, 22 Oct 2015 11:35:53 -0400
Subject: [lustre-devel] [PATCH 0/3] Minor cleanup for locks API
Message-ID: <cover.1445524157.git.bcodding@redhat.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

NFS has recently been moving things around to cope with the situation where
a struct file may not be available during an unlock.  That work has
presented an opportunity to do a minor cleanup on the locks API.

Users of posix_lock_file_wait() (for FL_POSIX style locks) and
flock_lock_file_wait() (for FL_FLOCK style locks) can instead call
locks_lock_file_wait() for both lock types.  Because the passed-in file_lock
specifies its own type, the correct function can be selected on behalf of
the user.

This work allows further cleanup within NFS and lockd which will be
submitted separately.

Benjamin Coddington (3):
  locks: introduce locks_lock_inode_wait()
  Move locks API users to locks_lock_inode_wait()
  locks: cleanup posix_lock_inode_wait and flock_lock_inode_wait

 drivers/staging/lustre/lustre/llite/file.c |    8 +-----
 fs/9p/vfs_file.c                           |    4 +-
 fs/ceph/locks.c                            |    4 +-
 fs/cifs/file.c                             |    2 +-
 fs/dlm/plock.c                             |    4 +-
 fs/fuse/file.c                             |    2 +-
 fs/gfs2/file.c                             |    8 +++---
 fs/lockd/clntproc.c                        |   13 +----------
 fs/locks.c                                 |   31 +++++++++++++++++++++++----
 fs/nfs/file.c                              |   13 +----------
 fs/nfs/nfs4proc.c                          |   13 +----------
 fs/ocfs2/locks.c                           |    8 +++---
 include/linux/fs.h                         |   21 +++---------------
 13 files changed, 51 insertions(+), 80 deletions(-)
