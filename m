From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  7 Dec 2016 17:41:26 -0500
Subject: [lustre-devel] [PATCH 0/8] Sparse warning fixes in Lustre.
Message-ID: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

This set of fixes aims at sparse warnings.
Most of the patches are just moving declarations around
to deal with the
warning: symbol 'xxx' was not declared. Should it be static?
kind of messages.

Also a screwup with root_squash sysfs control is fixed.

Oleg Drokin (8):
  staging/lustre/llite: move root_squash from sysfs to debugfs
  staging/lustre/ldlm: Correct itree_overlap_cb return type
  staging/lustre/llite: mark ll_io_init() static
  staging/lustre/lov: make lov_lsm_alloc() static
  staging/lustre/osc: extern declare osc_caches in a header
  staging/lustre: Declare lu_context/session_tags_default
  staging/lustre: Move lov_read_and_clear_async_rc declaration
  staging/lustre/ptlrpc: Move nrs_conf_fifo extern to a header

 drivers/staging/lustre/lustre/include/lu_object.h  |  3 +++
 drivers/staging/lustre/lustre/include/obd.h        |  3 +++
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  2 +-
 drivers/staging/lustre/lustre/llite/file.c         |  2 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 27 ++++++++++++----------
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  2 --
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  3 ++-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  3 +--
 drivers/staging/lustre/lustre/osc/osc_internal.h   |  2 ++
 drivers/staging/lustre/lustre/osc/osc_request.c    |  2 --
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |  3 ---
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  3 +++
 12 files changed, 31 insertions(+), 24 deletions(-)

-- 
2.7.4
