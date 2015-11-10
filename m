From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Tue, 10 Nov 2015 10:21:00 +0530
Subject: [lustre-devel] [PATCH v2 0/8] Remove wrapper function and clean up
	the code
Message-ID: <cover.1447129813.git.shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patchset removes an unnecessary wrapper function, its prototype and
replaces all its calls in different files with the standard function
that it wraps.
After applying this patch, code becomes cleaner.

Changes in v2:
        Fix commit message and merge a patch

Shivani Bhardwaj (8):
  Staging: lustre: dir: Replace function calls
  Staging: lustre: file: Replace function calls with standard function
  Staging: lustre: namei: Replace calls with kfree
  Staging: lustre: xattr_cache: Change function calls to kfree
  Staging: lustre: symlink: Substitute standard function
  Staging: lustre: llite_nfs: Replace function calls with kfree
  Staging: lustre: llite_close: Substitute function calls
  Staging: lustre: llite: Remove ll_finish_md_op_data wrapper

 drivers/staging/lustre/lustre/llite/dir.c          | 14 ++++++-------
 drivers/staging/lustre/lustre/llite/file.c         | 24 +++++++++++-----------
 drivers/staging/lustre/lustre/llite/llite_close.c  |  2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  1 -
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 13 ++++--------
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  2 +-
 drivers/staging/lustre/lustre/llite/namei.c        | 12 +++++------
 drivers/staging/lustre/lustre/llite/symlink.c      |  2 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  2 +-
 9 files changed, 33 insertions(+), 39 deletions(-)

-- 
2.1.0
