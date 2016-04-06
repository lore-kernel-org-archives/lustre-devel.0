From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:26 -0400
Subject: [lustre-devel] [PATCH 00/24] staging: lustre: selftest: remove
	typedefs
Message-ID: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The lnet selftest code is littered with typedefs. Convert these
typedefs into their proper data types.

James Simmons (24):
  staging: lustre: selftest: convert srpc_event_type to proper enum
  staging: lustre: selftest: convert srpc_event_t to proper struct
  staging: lustre: selftest: convert srpc_bulk_t to proper struct
  staging: lustre: selftest: convert srpc_buffer_t to proper struct
  staging: lustre: selftest: convert swi_workitem_t to proper struct
  staging: lustre: selftest: convert srpc_client_rpc_t to proper struct
  staging: lustre: selftest: convert srpc_service_t to proper struct
  staging: lustre: selftest: convert sfw_session_t to proper struct
  staging: lustre: selftest: convert sfw_batch_t to proper struct
  staging: lustre: selftest: convert sfw_test_client_ops_t to proper struct
  staging: lustre: selftest: convert sfw_test_instance_t to proper struct
  staging: lustre: selftest: convert sfw_test_unit_t to proper struct
  staging: lustre: selftest: convert sfw_test_case_t to proper struct
  staging: lustre: selftest: convert lstcon_rpc_t to proper struct
  staging: lustre: selftest: convert lstcon_rpc_trans_t to proper struct
  staging: lustre: selftest: convert lstcon_node_t to proper struct
  staging: lustre: selftest: convert lstcon_ndlink_t to proper struct
  staging: lustre: selftest: convert lstcon_group_t to proper struct
  staging: lustre: selftest: convert lstcon_tsb_hdr_t to proper struct
  staging: lustre: selftest: convert lstcon_batch_t to proper struct
  staging: lustre: selftest: convert lstcon_test_t to proper struct
  staging: lustre: selftest: convert srpc_msg_t to proper struct
  staging: lustre: selftest: convert wire protocol to use struct
  staging: lustre: selftest: change srpc_state_t to proper enum

 drivers/staging/lustre/lnet/selftest/brw_test.c  |   76 +++---
 drivers/staging/lustre/lnet/selftest/conctl.c    |    2 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c    |  196 ++++++++--------
 drivers/staging/lustre/lnet/selftest/conrpc.h    |   40 ++--
 drivers/staging/lustre/lnet/selftest/console.c   |  271 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/console.h   |   47 ++--
 drivers/staging/lustre/lnet/selftest/framework.c |  256 ++++++++++----------
 drivers/staging/lustre/lnet/selftest/ping_test.c |   42 ++--
 drivers/staging/lustre/lnet/selftest/rpc.c       |  123 +++++-----
 drivers/staging/lustre/lnet/selftest/rpc.h       |  156 +++++++------
 drivers/staging/lustre/lnet/selftest/selftest.h  |  200 ++++++++--------
 11 files changed, 714 insertions(+), 695 deletions(-)
