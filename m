From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:43 -0400
Subject: [lustre-devel] [PATCH 00/29] Removal of unused Lustre code
Message-ID: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This set removes a bunch of lustre code that is no lonver relevant,
is server specific or is otherwise unused.

Please consider.

More to come later.

Arnd Bergmann (1):
  staging/lustre: remove lots of dead code

Oleg Drokin (28):
  staging/lustre: Remove unused target_print_req()
  staging/lustre: Remove unused lustre_acl_xattr_merge2posix()
  staging/lustre/ptlrpc: Remove server-specific health checks
  staging/lustre: Remove unused req_capsule_server_grow
  staging/lustre: Remove unused reply state batches code
  staging/lustre: Remove high-priority request callbacks
  staging/lustre: Remove unused statfs_pack()
  staging/lustre: Remove unused ptlrpcd_add_rqset()
  staging/lustre: Remove unused functions and definitions from cl_object
  staging/lustre: Remove unused lu_object functions.
  staging/lustre/ldlm: Remove unused round_timeout function
  staging/lustre/obdclass: Remove unused functions from genops.c
  staging/lustre: Remove unused function class_handle_hash_back()
  staging/lustre: Remove unused function server_name2svname()
  staging/lustre/obdclass: Drop unused code from obdo.c
  staging/lustre/ptlrpc: Drop unused client code
  staging/lustre/ptlrpc: secure wrapping code cleanup
  staging/lustre: Drop unused obdo_from_la() and la_from_obdo()
  staging/lustre/fid: Remove server fid function declarations
  staging/lustre/fid: seq_client_init/fini don't need to be exported
  staging/lustre/fid: Remove unused seq_client_get_seq function
  staging/lustre/fid: Get rid of lcs_srv in lu_client_seq
  staging/lustre/fid: Remove unused struct lu_server_seq
  staging/lustre/obdclass: Remove unused nid_hash
  staging/lustre: Remove server-only recovery-related bits
  staging/lustre: Remove ccc_attr/conf_set()
  staging/lustre: Remove unused ccc_io_fini()
  staging/lustre: Remove ccc_transient_page_* methods

 drivers/staging/lustre/lustre/fid/fid_request.c    | 132 ++------
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |   2 -
 drivers/staging/lustre/lustre/include/cl_object.h  |  26 --
 drivers/staging/lustre/lustre/include/lclient.h    |  24 --
 .../staging/lustre/lustre/include/lprocfs_status.h |   4 -
 drivers/staging/lustre/lustre/include/lu_object.h  |  27 --
 .../lustre/lustre/include/lustre/lustre_idl.h      |   8 -
 .../lustre/lustre/include/lustre/lustre_user.h     |   2 -
 .../staging/lustre/lustre/include/lustre_debug.h   |   1 -
 .../staging/lustre/lustre/include/lustre_disk.h    |   2 -
 .../staging/lustre/lustre/include/lustre_eacl.h    |   4 -
 .../staging/lustre/lustre/include/lustre_export.h  |  19 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |  91 ------
 .../staging/lustre/lustre/include/lustre_handles.h |   1 -
 .../staging/lustre/lustre/include/lustre_import.h  |   1 -
 drivers/staging/lustre/lustre/include/lustre_lib.h |   1 -
 drivers/staging/lustre/lustre/include/lustre_net.h |  42 +--
 .../staging/lustre/lustre/include/lustre_param.h   |   6 -
 .../lustre/lustre/include/lustre_req_layout.h      |   7 -
 drivers/staging/lustre/lustre/include/lustre_sec.h |  20 --
 drivers/staging/lustre/lustre/include/obd.h        |  29 --
 drivers/staging/lustre/lustre/include/obd_class.h  |  28 --
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c |  70 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   5 -
 drivers/staging/lustre/lustre/obdclass/acl.c       | 119 -------
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  65 ----
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |  26 --
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  41 ---
 drivers/staging/lustre/lustre/obdclass/debug.c     |  10 -
 drivers/staging/lustre/lustre/obdclass/genops.c    | 249 +-------------
 .../lustre/lustre/obdclass/linux/linux-obdo.c      | 137 --------
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |   4 -
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 241 --------------
 .../lustre/lustre/obdclass/lustre_handles.c        |  13 -
 .../staging/lustre/lustre/obdclass/obd_config.c    | 358 ---------------------
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  27 --
 drivers/staging/lustre/lustre/obdclass/obdo.c      | 170 ----------
 .../staging/lustre/lustre/obdclass/statfs_pack.c   |  14 -
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  95 ------
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  11 -
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 126 --------
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  30 --
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   3 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         | 123 -------
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 197 ------------
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |  18 --
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |   8 -
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |  42 ---
 drivers/staging/lustre/lustre/ptlrpc/sec.c         | 116 -------
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    | 329 -------------------
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |  48 ---
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |  15 -
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 320 ++----------------
 53 files changed, 62 insertions(+), 3445 deletions(-)

-- 
2.1.0
