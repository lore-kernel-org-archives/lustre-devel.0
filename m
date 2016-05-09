From: James Simmons <jsimmons@infradead.org>
Date: Mon,  9 May 2016 10:53:44 -0400
Subject: [lustre-devel] [PATCH 0/4] staging: lustre: small recent fixes for
	LNet/libcfs
Message-ID: <1462805628-23403-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Here are various fixes and improvements for the libcfs
and LNet layer. Two memory leaks fixed as well as adding
container support for the ko2iblnd driver. Lastly handle
the lower limit of the mlx5 driver for cap.max_send_wr.

Dmitry Eremin (1):
  staging: lustre: o2iblnd: limit cap.max_send_wr for MLX5

James Simmons (2):
  staging: lustre: libcfs: fix memort leak in libcfs crypto layer
  staging: lustre: ko2iblnd: fix memory corruption with fragments

Li Dongyang (1):
  staging: lustre: o2iblnd: make rdma_create_id() support containers

 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   20 +++++++++++++++-----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    8 ++++++++
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    1 +
 4 files changed, 25 insertions(+), 6 deletions(-)
