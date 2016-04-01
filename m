From: Joe Perches <joe@perches.com>
Date: Fri,  1 Apr 2016 06:02:08 -0700
Subject: [lustre-devel] [RFC PATCH 0/3] staging: lustre: detypedef
Message-ID: <cover.1459515208.git.joe@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org

Question about removing lustre typedefs.

Various bits of lustre code use a mix of struct foo and foo_t.

When would be an appropriate time to submit patches similar to
below that individually remove various typedefs from lustre code?

These are pretty trivial to produce and verify so there's no
particular hurry to do them now but applying them will require
resync points for active and actually useful developers.

A few scripted examples are done:

Joe Perches (3):
  staging: lustre: Remove typedef lnet_peer_t
  staging: lustre: Remove typedef lnd_t
  staging: lustre: Remove typedef lnet_msg_t

 .../staging/lustre/include/linux/lnet/lib-lnet.h   | 62 +++++++--------
 .../staging/lustre/include/linux/lnet/lib-types.h  | 22 +++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  4 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  6 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  8 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  6 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  6 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 16 ++--
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 92 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/lib-msg.c         | 24 +++---
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  4 +-
 drivers/staging/lustre/lnet/lnet/lo.c              |  8 +-
 drivers/staging/lustre/lnet/lnet/peer.c            | 30 +++----
 drivers/staging/lustre/lnet/lnet/router.c          | 28 +++----
 drivers/staging/lustre/lnet/lnet/router_proc.c     |  4 +-
 16 files changed, 161 insertions(+), 161 deletions(-)

-- 
2.8.0.rc4.16.g56331f8
