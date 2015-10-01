From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:10 -0400
Subject: [lustre-devel] [PATCH 00/32] Lustre (mostly locking) unused code
	removal
Message-ID: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This continues the quest for killing unused code in the Lustre client.

Main focus in this set is on Lustre LDLM code - it kills both
outright unused code and code that looks like it's used, but in fact
also unused as various conditions that would lead to it would only
happen on the server. Also LDLM is cleaned up to remove unneeded exported
symbols and (almost) all locally used functions are now declared as static.

Also a few patches to llite/lov to remove some unused functions there.

Please consider.

Oleg Drokin (32):
  staging/lustre/llite: Remove unused ll_get_default/max_cookiesize()
  staging/lustre: KEY_DEFAULT/MAX_COOKIESIZE key is unused, remove them
  staging/lustre: Remove ununused ll_ra_read_get()
  staging/lustre/llite: Remove unused ll_rmdir_entry()
  staging/lustre/lov: Remove unused lov_dump_lmm/pool()
  staging/lustre/lov: Remove unused lov_lsm_decref()
  staging/lustre/ldlm: Remove unused interval tree bits
  staging/lustre/ldlm: Remove unused ldlm_cancel_locks_for_exports()
  staging/lustre/ldlm: Remove ldlm_init/destroy_export()
  staging/lustre/ldlm: Remove unimplemented lock conversion traces.
  staging/lustre/ldlm: Get rid of lr_converting queue
  staging/lustre/ldlm: Remove unused ldlm_cli_enqueue_local()
  staging/lustre/ldlm: Remove unused ldlm_init/fini_flock_export
  staging/lustre/ldlm: Remove unused ldlm_enqueue_pack()
  staging/lustre/ldlm: Remove ldlm_errno2error()
  staging/lustre/ldlm: Remove ldlm_glimpse_ast()
  staging/lustre/ldlm: Remove ldlm_lock_fail_match()
  staging/lustre/ldlm: Remove ldlm_namespace_free()
  staging/lustre/ldlm: Remove unused ldlm_pool_get_clv()
  staging/lustre/ldlm: Remove unused ldlm_pool_set_slv()
  staging/lustre/ldlm: Remove ldlm_refresh/del_waiting_lock()
  staging/lustre/ldlm: Remove intent policies handler.
  staging/lustre/ldlm: Remove unused ldlm_reprocess_all*()
  staging/lustre/ldlm: Remove unused ldlm_resource_insert_lock_after()
  staging/lustre/ldlm: Remove unused ldlm_blocking_ast/_nocheck()
  staging/lustre: Remove ns_is_client()
  staging/lustre: Remove ns_is_server()
  staging/lustre/ldlm: Remove server side code from pool support.
  staging/lustre/ldlm: Remove unused exported symbols.
  staging/lustre/ldlm: Remove ldlm_namespace_inactive_list()
  staging/lustre/ldlm: Remove posix lock (flock) deadlock detection
  staging/lustre/ldlm: Make ldlm_add_ast_work_item() static

 .../staging/lustre/lustre/include/interval_tree.h  |  36 --
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 103 +----
 drivers/staging/lustre/lustre/include/obd.h        |   2 -
 drivers/staging/lustre/lustre/ldlm/interval_tree.c | 271 --------------
 drivers/staging/lustre/lustre/ldlm/l_lock.c        |   7 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |  22 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    | 269 +------------
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  36 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  36 --
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 380 ++-----------------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 122 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 416 ++-------------------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 338 +----------------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 181 +++------
 .../staging/lustre/lustre/llite/llite_internal.h   |   4 -
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  26 --
 drivers/staging/lustre/lustre/llite/namei.c        |  28 --
 drivers/staging/lustre/lustre/llite/rw.c           |  24 --
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   2 -
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |   3 -
 drivers/staging/lustre/lustre/lov/lov_internal.h   |   2 -
 drivers/staging/lustre/lustre/lov/lov_object.c     |  13 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  20 -
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  22 --
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  20 -
 25 files changed, 155 insertions(+), 2228 deletions(-)

-- 
2.1.0
