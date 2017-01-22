From: James Simmons <jsimmons@infradead.org>
Date: Sat, 21 Jan 2017 19:40:24 -0500
Subject: [lustre-devel] [PATCH 0/8] staging: lustre: lnet: change wire
	protocol typedefs to proper structure
Message-ID: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The upstream kernel requires proper structures so
convert nearly all the LNet wire protocols typedefs in
the LNet core.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/24566
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>

James Simmons (8):
  staging: lustre: lnet: change lnet_handle_wire_t to proper structure
  staging: lustre: lnet: change lnet_ping_info_t to proper structure
  staging: lustre: lnet: change lnet_ni_status_t to proper structure
  staging: lustre: lnet: change lnet_process_id_packed_t to proper structure
  staging: lustre: lnet: change lnet_acceptor_connreq_t to proper structure
  staging: lustre: lnet: change lnet_magicversion_t to proper structure
  staging: lustre: lnet: change lnet_hdr_t to proper structure
  staging: lustre: lnet: change msg union in struct lnet_hdr to proper structure

 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  14 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |  10 +-
 .../staging/lustre/include/linux/lnet/socklnd.h    |   2 +-
 drivers/staging/lustre/include/linux/lnet/types.h  |  70 ++++-----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   6 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  14 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |  26 ++--
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   6 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 170 ++++++++++-----------
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  20 +--
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   4 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |   2 +-
 drivers/staging/lustre/lnet/lnet/net_fault.c       |   4 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  10 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |  10 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |   8 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |   2 +-
 19 files changed, 191 insertions(+), 191 deletions(-)

-- 
1.8.3.1
