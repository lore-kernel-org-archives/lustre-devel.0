From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 18:53:23 -0500
Subject: [lustre-devel] [PATCH 0/7] All remaining outstanding bug fixes for
	ko2iblnd
Message-ID: <1456962810-21806-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Final missing bug fixes to bring the infiniband LND driver up
to date with the latest code used in production system.

Amir Shehata (1):
  staging: lustre: make ko2iblnd connect parameters persistent

Doug Oucharek (1):
  staging: lustre: Change connect peer failed cleanup order

Jeremy Filizetti (1):
  staging: lustre: Support different ko2iblnd configs between systems

Liang Zhen (4):
  staging: lustre: take extra refcount in kiblnd_connreq_done
  staging: lustre: check wr_id returned by ib_poll_cq
  staging: lustre: avoid intensive reconnecting for ko2iblnd
  staging: lustre: do less intense allocating retry for ko2iblnd

 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  105 +++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  101 ++++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  433 ++++++++++++++------
 3 files changed, 443 insertions(+), 196 deletions(-)
