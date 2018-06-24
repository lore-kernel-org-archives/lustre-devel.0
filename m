From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:53:44 -0400
Subject: [lustre-devel] [PATCH 0/8] staging: lustre: lnet: resolve time
 handling issues
Message-ID: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The migration of lustre to 64 bit time handling exposed various bugs
which have lead to problems like routers no longer functioning with
the upstream client. This is due to the complex handling of time by
lustre with seconds time units and jiffies. Add in the fact that
jiffies can vary from node to node and you can encounter corner
case issues in a large node deployment. The solution to resolve this
was to migrate as much as possible to time64_t when all you needed
was seconds percision and ktime_t if better percision was required.
With these changes it is reduced down to using jiffies only for
schedule_timeout calls.

James Simmons (8):
  staging: lustre: lnet: simplify lnet_eq_wait_locked
  staging: lustre: o2iblnd: use ktime_get_real_ns for ibn_incarnation
  staging: lustre: ksocklnd: use ktime_get_real_ns for ksnn_incarnation
  staging: lustre: ksocklnd: move remaining time handling to 64 bits
  staging: lustre: lnet: use ktime_get_real_ns for cookie creation
  staging: lustre: lnet: move ping and delay injection to time64_t
  staging: lustre: ko2iblnd: remove remaining jiffy use
  staging: lustre: selftest: fix time reporting

 drivers/staging/lustre/include/linux/lnet/api.h    |   2 +-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   8 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |  13 ++-
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |   2 -
 .../lustre/include/uapi/linux/lnet/lnetst.h        |   2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  53 +++++-----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  28 ++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  36 +++----
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  44 ++++----
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  22 ++--
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 117 ++++++++++-----------
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  54 ++++++----
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |  26 ++---
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  24 ++---
 drivers/staging/lustre/lnet/lnet/net_fault.c       |  72 ++++++-------
 drivers/staging/lustre/lnet/lnet/peer.c            |   2 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  35 +++---
 drivers/staging/lustre/lnet/lnet/router_proc.c     |  27 +++--
 drivers/staging/lustre/lnet/selftest/conrpc.c      |  39 +++----
 drivers/staging/lustre/lnet/selftest/conrpc.h      |   2 +-
 drivers/staging/lustre/lnet/selftest/console.c     |   4 +-
 drivers/staging/lustre/lnet/selftest/console.h     |   2 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |   4 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |   2 +-
 drivers/staging/lustre/lnet/selftest/timer.c       |   8 +-
 25 files changed, 304 insertions(+), 324 deletions(-)

-- 
1.8.3.1
