From: James Simmons <jsimmons@infradead.org>
Date: Wed, 28 Oct 2015 12:54:21 -0400
Subject: [lustre-devel] [PATCH 00/10] staging: lustre: cleanup up libcfs
	hash code for upstream
Message-ID: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

This patch brings the libcfs hash handling up to linux
kernel coding style. Various typedefs and macros have
been removed.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/14624
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>

James Simmons (10):
  staging: lustre: change cfs_hash_lock_ops_t to struct
  staging: lustre: change cfs_hash_hlist_ops_t to struct
  staging: lustre: change cfs_hash_ops_t to struct
  staging: lustre: change cfs_hash_dhead*_t to struct
  staging: lustre: change cfs_hash_head*_t to struct
  staging: lustre: convert last typedef data types in hash.c
  staging: lustre: cleanup over 80 characters in libcfs_hash.h
  staging: lustre: remove white space in libcfs_hash.h
  staging: lustre: fix remaining checkpatch issues for libcfs_hash.h
  staging: lustre: remove white space in hash.c

 .../lustre/include/linux/libcfs/libcfs_hash.h      |  350 +++++++++-------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   18 +-
 drivers/staging/lustre/lustre/libcfs/hash.c        |  447 ++++++++++----------
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    2 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |    6 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |    6 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    6 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |    8 +-
 drivers/staging/lustre/lustre/osc/osc_quota.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |    8 +-
 10 files changed, 451 insertions(+), 402 deletions(-)
