From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:43 -0500
Subject: [lustre-devel] [PATCH 00/27] Third batch of LNet fixes
Message-ID: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This patch set merges all the fixes for the klnd drivers, socklnd and
o2iblnd, to what is currently used in production environments. Several
more fixes for the LNet core are also included with this patch set.

Alyona Romanenko (1):
  staging: lustre: issue in the offset in lnet match hash table

Amir Shehata (3):
  staging: lustre: change ibh_mrs from array to pointer
  staging: lustre: make ko2iblnd connect parameters persistent
  staging: lustre: Ignore hops if not explicitly set

Dmitry Eremin (4):
  staging: lustre: fix socklnd issues found by Klocwork Insight tool
  staging: lustre: fix api-ni.c issues found by Klocwork Insight tool
  staging: lustre: fix conctl.c issues found by Klocwork Insight tool
  staging: lustre: fix framework.c issues found by Klocwork Insight tool

Doug Oucharek (1):
  staging: lustre: Change connect peer failed cleanup order

Frank Zago (3):
  staging: lustre: make o2iblnd local functions static
  staging: lustre: make o2iblnd_cb.c local functions static
  staging: lustre: corrected some typos and grammar errors

James Simmons (3):
  staging: lustre: return proper error code for LNet core
  staging: lustre: bind socklnd peers to a specific CPT
  staging: lustre: reverse LNet and infinband header order

Jeremy Filizetti (1):
  staging: lustre: Support different ko2iblnd configs between systems

Jian Yu (1):
  staging: lustre: replace direct LNet HZ access with kernel APIs

John L. Hammond (1):
  staging: lustre: set task state before scheduling in lnet_sock_accept

Li Xi (1):
  staging: lustre: remove annoying message in parse_nidrange

Liang Zhen (6):
  staging: lustre: set downis to 1 if there's no NI for remote net
  staging: lustre: recv could access freed message
  staging: lustre: take extra refcount in kiblnd_connreq_done
  staging: lustre: check wr_id returned by ib_poll_cq
  staging: lustre: avoid intensive reconnecting for ko2iblnd
  staging: lustre: do less intense allocating retry for ko2iblnd

Olaf Weber (1):
  staging: lustre: Use after free in lnet_ptl_match_delay()

Sebastien Buisson (1):
  staging: lustre: fix 'copy into fixed size buffer' errors

 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  230 ++++------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  135 ++++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  475 ++++++++++++++------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    7 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    8 +-
 drivers/staging/lustre/lnet/lnet/config.c          |   14 +-
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   51 ++-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |   93 +++--
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   45 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    3 +-
 drivers/staging/lustre/lnet/lnet/router.c          |   22 +-
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 +-
 drivers/staging/lustre/lnet/selftest/conctl.c      |    9 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    2 +-
 drivers/staging/lustre/lnet/selftest/console.c     |   23 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |   14 +-
 drivers/staging/lustre/lustre/libcfs/workitem.c    |    6 +-
 drivers/staging/lustre/lustre/llite/dir.c          |    6 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |    8 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |    7 +-
 25 files changed, 715 insertions(+), 455 deletions(-)
