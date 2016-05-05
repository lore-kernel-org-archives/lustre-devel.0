From: James Simmons <jsimmons@infradead.org>
Date: Thu,  5 May 2016 14:52:59 -0400
Subject: [lustre-devel] [PATCH 0/8] staging: lustre: o2iblnd: Add Fast Reg
	memory registration support
Message-ID: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

FMR is deprecated and it not supported by the mlx5 driver.
This patch adds memory management extensions support as
backup of FMR. This was combined with the work from
Li Dongyang to make it work with the latest kernels.

Dmitry Eremin (8):
  staging: lustre: o2iblnd: rename kib_fmr_pool_t
  staging: lustre: o2iblnd: Use list_for_each_entry_safe in kiblnd_destroy_fmr_pool_list
  staging: lustre: o2iblnd: create union to contain FMR
  staging: lustre: o2iblnd: break up kiblnd_create_fmr_pool
  staging: lustre: o2iblnd: cache FMR key in kib_fmr_t
  staging: lustre: o2iblnd: handle unmapping of FMR in kiblnd_fmr_pool_unmap
  staging: lustre: o2iblnd: add IBLND_WID_MR
  staging: lustre: o2iblnd: Add Fast Reg memory registration support

 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  312 +++++++++++++++++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   33 ++-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   58 ++--
 3 files changed, 322 insertions(+), 81 deletions(-)
