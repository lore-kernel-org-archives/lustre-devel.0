From: Benjamin Coddington <bcodding@redhat.com>
Date: Tue, 27 Jun 2017 11:18:06 -0400
Subject: [lustre-devel] [PATCH 0/3 v6] Fixups for l_pid
Message-ID: <cover.1498572504.git.bcodding@redhat.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Andreas Dilger <andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, James Simmons <jsimmons-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Ron Minnich <rminnich-4OHPYypu0djtX7QSmKvirg@public.gmane.org>, Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>, "Yan, Zheng" <zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Sage Weil <sage-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Christine Caulfield <ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Teigland <teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Vitaly Fertman <vitaly_fertman-qCPWdT176rRBDgjK7y7TUQ@public.gmane.org>, "John L. Hammond" <john.hammond-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Andriy Skulysh <andriy.skulysh-ShLqkCeKS0lBDgjK7y7TUQ@public.gmane.org>, Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Emoly Liu <emoly.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

LTP fcntl tests (fcntl11 fcntl14 fcntl17 fcntl19 fcntl20 fcntl21) have been
failing for NFSv4 mounts due to an unexpected l_pid.  What follows are some
fixups:

v2: - Rebase onto linux-next
    - Revert back to using the stack in locks_mandatory_area(), and fixup
	patch description for 1/3

v3: - The lkp-robot found some serious per_thread_ops performance
	regressions for v1 and v2, so this version changes things around to not
	acquire a reference to struct pid in fl_nspid for every lock.  Instead,
	it drops fl_nspid altogether, and defers the lookup of the
	namespace-translated pid until it actually needed.

v4: - Instead of looking up the virtual pid by way of referencing the struct
	task of the that pid, instead use find_pid_ns() and pid_nr_ns(), which
	avoids a the problem where we race to get a reference to the struct task
	while it may be freed.

v5: - Squash previous 2/3 and 3/3 to avoid regression where F_GETLK would
	return the init_ns pid instead of a translated pid.

v6: - State clearly how the differing cases of l_pid translation should be
	handled, specifically regarding remote locks on remote files: that
	fl_pid ought to be returned from the filesystem as <= 0 to indicate that
	it makes no sense to translate this l_pid.
	- Follow up with a patch to have filesystems negate fl_pid for remote
	locks on remote files.

Benjamin Coddington (3):
  fs/locks: Use allocation rather than the stack in fcntl_getlk()
  fs/locks: Remove fl_nspid and use fs-specific l_pid for remote locks
  staging/lustre, 9p, ceph, cifs, dlm: negate remote pids for F_GETLK

 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |   2 +-
 fs/9p/vfs_file.c                                |   2 +-
 fs/ceph/locks.c                                 |   2 +-
 fs/cifs/cifssmb.c                               |   2 +-
 fs/dlm/plock.c                                  |   2 +-
 fs/fuse/file.c                                  |   6 +-
 fs/locks.c                                      | 108 ++++++++++++++----------
 include/linux/fs.h                              |   2 +-
 8 files changed, 72 insertions(+), 54 deletions(-)

-- 
2.9.3
