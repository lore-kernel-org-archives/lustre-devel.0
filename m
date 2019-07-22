From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:23:29 -0400
Subject: [lustre-devel] [PATCH 00/22] [RFC] ldiskfs patches against 5.2-rc2+
Message-ID: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

With the work of Shaun Tancheff from Cray to bring the ldiskfs patches
in sync with the kernel in Neil's kernel source tree it was a easy
port from OpenSFS to the kernel proper. This is just to start the
discussion on how to move forward main streaming what Lustre has
done with ext4. So let the flames begin!!!!

James Simmons (22):
  ext4: add i_fs_version
  ext4: use d_find_alias() in ext4_lookup
  ext4: prealloc table optimization
  ext4: export inode management
  ext4: various misc changes
  ext4: add extra checks for mballoc
  ext4: update .. for hash indexed directory
  ext4: kill off struct dx_root
  ext4: fix mballoc pa free mismatch
  ext4: add data in dentry feature
  ext4: over ride current_time
  ext4: add htree lock implementation
  ext4: Add a proc interface for max_dir_size.
  ext4: remove inode_lock handling
  ext4: remove bitmap corruption warnings
  ext4: add warning for directory htree growth
  ext4: optimize ext4_journal_callback_add
  ext4: attach jinode in writepages
  ext4: don't check before replay
  ext4: use GFP_NOFS in ext4_inode_attach_jinode
  ext4: export ext4_orphan_add
  ext4: export mb stream allocator variables

 fs/ext4/Makefile     |   4 +-
 fs/ext4/balloc.c     |  11 +-
 fs/ext4/dir.c        |  14 +-
 fs/ext4/ext4.h       | 225 +++++++++++-
 fs/ext4/ext4_jbd2.c  |   4 +
 fs/ext4/ext4_jbd2.h  |   2 +-
 fs/ext4/hash.c       |   1 +
 fs/ext4/htree_lock.c | 891 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/ext4/htree_lock.h | 187 ++++++++++
 fs/ext4/ialloc.c     |  10 +-
 fs/ext4/inline.c     |  16 +-
 fs/ext4/inode.c      |  24 +-
 fs/ext4/mballoc.c    | 479 +++++++++++++++++++------
 fs/ext4/mballoc.h    |   4 +-
 fs/ext4/namei.c      | 978 +++++++++++++++++++++++++++++++++++++++++++--------
 fs/ext4/super.c      |  27 +-
 fs/ext4/sysfs.c      |  20 +-
 17 files changed, 2601 insertions(+), 296 deletions(-)
 create mode 100644 fs/ext4/htree_lock.c
 create mode 100644 fs/ext4/htree_lock.h

-- 
1.8.3.1
