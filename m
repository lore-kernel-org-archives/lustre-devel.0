From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:25 -0500
Subject: [lustre-devel] [PATCH 00/34] staging: lustre: lnet: remove most of
	typedefs from LNet headers
Message-ID: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove the majority of typedefs from the LNet headers.
Change them into structures or enums instead. Currently
only lnet_nid_t are lnet_pid_t are left. Removed the
rest of the typedefs in socklnd.h as well

James Simmons (34):
  staging: lustre: socklnd: change UAPI typedefs to proper structure
  staging: lustre: lnet: change lnet_handle_eq_t to proper struct
  staging: lustre: lnet: change lnet_handle_md_t to proper struct
  staging: lustre: lnet: change lnet_handle_me_t to proper struct
  staging: lustre: lnet: remove generic lnet_handle_any_t
  staging: lustre: lnet: change lnet_msg_t to proper structure
  staging: lustre: lnet: change lnet_libhandle_t to proper structure
  staging: lustre: lnet: change lnet_eq_t to proper structure
  staging: lustre: lnet: change lnet_me_t to proper structure
  staging: lustre: lnet: change lnet_libmd_t to proper structure
  staging: lustre: lnet: change lnet_test_peer_t to proper structure
  staging: lustre: lnet: change lnd_t to proper structure
  staging: lustre: lnet: change lnet_ni_t to proper structure
  staging: lustre: lnet: change lnet_rc_data_t to proper structure
  staging: lustre: lnet: change lnet_peer_t to proper structure
  staging: lustre: lnet: change lnet_route_t to proper structure
  staging: lustre: lnet: change lnet_remotenet_t to proper structure
  staging: lustre: lnet: change lnet_rtrbufpool_t to proper structure
  staging: lustre: lnet: change lnet_rtrbuf_t to proper structure
  staging: lustre: lnet: change lnet_portal_t to proper structure
  staging: lustre: lnet: change lnet_t to proper structure
  staging: lustre: lnet: give LNET_MATCH* enum a name
  staging: lustre: lnet: change lnet_counter_t to proper structure
  staging: lustre: lnet: change lnet_md_t to proper structure
  staging: lustre: lnet: change lnet_event_t to proper structure
  staging: lustre: lnet: change lnet_process_id_t to proper structure
  staging: lustre: lnet: change lnet_msg_type_t to proper enum
  staging: lustre: lnet: change lnet_unlink_t to proper enum
  staging: lustre: lnet: change lnet_ins_pos_t to proper enum
  staging: lustre: lnet: change lnet_event_kind_t to proper enum
  staging: lustre: lnet: change lnet_ack_req_t to proper enum
  staging: lustre: lnet: remove LNET_SEQ_BASETYPE
  staging: lustre: lnet: remove unused lnet_md_iovec_t
  staging: lustre: lnet: use struct bio_vec instead of typedef

 drivers/staging/lustre/include/linux/lnet/api.h    |  65 +++---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   | 232 +++++++++++----------
 .../staging/lustre/include/linux/lnet/lib-types.h  | 137 ++++++------
 drivers/staging/lustre/include/linux/lnet/lnetst.h |  12 +-
 drivers/staging/lustre/include/linux/lnet/nidstr.h |   2 +-
 .../staging/lustre/include/linux/lnet/socklnd.h    |  14 +-
 drivers/staging/lustre/include/linux/lnet/types.h  | 155 +++++++-------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  30 +--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  21 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  65 +++---
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |   2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  69 +++---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  76 +++----
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  54 ++---
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |   4 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |  38 ++--
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 151 +++++++-------
 drivers/staging/lustre/lnet/lnet/config.c          |   8 +-
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |  26 +--
 drivers/staging/lustre/lnet/lnet/lib-md.c          |  29 +--
 drivers/staging/lustre/lnet/lnet/lib-me.c          |  28 +--
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 195 ++++++++---------
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |  41 ++--
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  30 +--
 drivers/staging/lustre/lnet/lnet/lo.c              |  12 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |   2 +-
 drivers/staging/lustre/lnet/lnet/peer.c            |  38 ++--
 drivers/staging/lustre/lnet/lnet/router.c          | 164 ++++++++-------
 drivers/staging/lustre/lnet/lnet/router_proc.c     |  34 +--
 drivers/staging/lustre/lnet/selftest/brw_test.c    |   4 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |   6 +-
 drivers/staging/lustre/lnet/selftest/console.c     |  39 ++--
 drivers/staging/lustre/lnet/selftest/console.h     |  14 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |   4 +-
 drivers/staging/lustre/lnet/selftest/ping_test.c   |   2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |  31 +--
 drivers/staging/lustre/lnet/selftest/rpc.h         |   2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |  42 ++--
 drivers/staging/lustre/lustre/include/lustre_net.h |  32 +--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   2 +-
 drivers/staging/lustre/lustre/llite/super25.c      |   2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |   5 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  18 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  24 +--
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |   2 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |   2 +-
 49 files changed, 1004 insertions(+), 973 deletions(-)

-- 
1.8.3.1
