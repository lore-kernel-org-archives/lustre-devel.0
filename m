From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:03 -0500
Subject: [lustre-devel] [PATCH 00/34] staging: lustre: lnet: change lnet
	selftest UAPI typedefs to proper structure
Message-ID: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The upstream kernel requires proper structures so
convert all the UAPI typdefs in lnetst.h.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>

James Simmons (34):
  staging: lustre: lnet: change lst_nid_t to proper structure
  staging: lustre: lnet: change lst_bid_t to proper structure
  staging: lustre: lnet: change lstcon_node_ent_t to proper structure
  staging: lustre: lnet: change lstcon_ndlist_ent_t to proper structure
  staging: lustre: lnet: change lstcon_test_ent_t to proper structure
  staging: lustre: lnet: change lstcon_batch_ent_t to proper structure
  staging: lustre: lnet: change lstcon_test_batch_ent_t to proper structure
  staging: lustre: lnet: change lstcon_rpc_ent_t to proper structure
  staging: lustre: lnet: change lstcon_trans_stat_t to proper structure
  staging: lustre: lnet: change lstio_session_new_args_t to proper structure
  staging: lustre: lnet: change lstio_session_info_args_t to proper structure
  staging: lustre: lnet: change lstio_session_end_args_t to proper structure
  staging: lustre: lnet: change lstio_debug_args_t to proper structure
  staging: lustre: lnet: change lstio_group_add_args_t to proper structure
  staging: lustre: lnet: change lstio_group_del_args_t to proper structure
  staging: lustre: lnet: change lstio_group_update_args_t to proper structure
  staging: lustre: lnet: change lstio_group_nodes_args_t to proper structure
  staging: lustre: lnet: change lstio_group_list_args_t to proper structure
  staging: lustre: lnet: change lstio_group_info_args_t to proper structure
  staging: lustre: lnet: change lstio_batch_add_args_t to proper structure
  staging: lustre: lnet: change lstio_batch_del_args_t to proper structure
  staging: lustre: lnet: change lstio_batch_run_args_t to proper structure
  staging: lustre: lnet: change lstio_batch_stop_args_t to proper structure
  staging: lustre: lnet: change lstio_batch_query_args_t to proper structure
  staging: lustre: lnet: change lstio_batch_list_args_t to proper structure
  staging: lustre: lnet: change lstio_batch_info_args_t to proper structure
  staging: lustre: lnet: change lstio_stat_args_t to proper structure
  staging: lustre: lnet: change lst_test_type_t to proper enum
  staging: lustre: lnet: change lstio_test_args_t to proper structure
  staging: lustre: lnet: change lst_brw_[type|flags]_t to proper enum
  staging: lustre: lnet: change lst_test_bulk_param_t to proper structure
  staging: lustre: lnet: change lst_test_ping_param_t to proper structure
  staging: lustre: lnet: change srpc_counters_t to proper structure
  staging: lustre: lnet: change sfw_counter_t to proper structure

 drivers/staging/lustre/include/linux/lnet/lnetst.h | 198 ++++++++++-----------
 drivers/staging/lustre/lnet/selftest/conctl.c      |  76 ++++----
 drivers/staging/lustre/lnet/selftest/conrpc.c      |  26 +--
 drivers/staging/lustre/lnet/selftest/conrpc.h      |   4 +-
 drivers/staging/lustre/lnet/selftest/console.c     |  56 +++---
 drivers/staging/lustre/lnet/selftest/console.h     |  24 +--
 drivers/staging/lustre/lnet/selftest/framework.c   |  10 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |   6 +-
 drivers/staging/lustre/lnet/selftest/rpc.h         |  38 ++--
 drivers/staging/lustre/lnet/selftest/selftest.h    |   8 +-
 10 files changed, 223 insertions(+), 223 deletions(-)

-- 
1.8.3.1
