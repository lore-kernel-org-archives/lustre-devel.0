From: James Simmons <jsimmons@infradead.org>
Date: Thu,  9 Jun 2016 18:45:44 -0400
Subject: [lustre-devel] [PATCH 0/3] staging: lustre: lnet: bug fixs for
	4.7-rc2
Message-ID: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Here are the latest fixes for LNet. One fix covers a bug
for the infiniband driver that happens when the o2iblnd
intereface is pinged before it is finishing setting up.
The next patch set from Bruno adds kmem_caches for the
LNet layer.

Bruno Faccini (2):
  staging: lustre: lnet: Allocate MEs and small MDs in own kmem_caches
  staging: lustre: lnet: optimize memory foot print for lnet_libmd

Doug Oucharek (1):
  staging: lustre: lnet: Don't access NULL NI on failure path

 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   36 ++++++++++++++--
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    7 ++-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   45 ++++++++++++++++++++
 4 files changed, 82 insertions(+), 8 deletions(-)
