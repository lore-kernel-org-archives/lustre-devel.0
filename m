From: James Simmons <jsimmons@infradead.org>
Date: Fri,  6 May 2016 21:30:21 -0400
Subject: [lustre-devel] [PATCH 00/10] staging: lustre: lnet: per NI
	map-on-demand value
Message-ID: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Enables support of different map-on-demand values per NI.  This is
required to support OPA coexistence with MLX5 cards.  MLX5 does not
support FMR, which is enabled via map-on-demand.  However OPA's
performance is greatly enahanced when FMR is enabled.  In order
to enable coexistence of both of these two types of cards we
need to be able to set different map-on-demand values for both
NIs.

This patch also lays the ground work for other per NI tunables to
be added in future patches.

Amir Shehata (10):
  staging: lustre: lnet: use struct lnet_ioctl_config_data for NI bring up
  staging: lustre: lnet: use struct lnet_ioctl_config_data for NI query
  staging: lustre: lnet: add per NI configuration structures
  staging: lustre: o2iblnd: convert macros to inline functions
  staging: lustre: o2iblnd: create default o2iblnd tunable settings
  staging: lustre: o2iblnd: use data in lnet_ni_t instead of kiblnd_tunables
  staging: lustre: o2iblnd: per NI map-on-demand value
  staging: lustre: o2iblnd: remove last of kiblnd_tunables_fini
  staging: lustre: o2iblnd: properly set ibr_why
  staging: lustre: lnet: enable configuration per NI interface

 .../staging/lustre/include/linux/lnet/lib-dlc.h    |   29 ++++-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    9 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   83 +++++++-----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  101 ++++++++------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   36 +++---
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  139 ++++++++++++++------
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  139 ++++++++++++--------
 drivers/staging/lustre/lnet/lnet/config.c          |    3 +
 drivers/staging/lustre/lnet/lnet/module.c          |    7 +-
 10 files changed, 341 insertions(+), 207 deletions(-)
