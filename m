From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Dec 2017 10:01:47 +1100
Subject: [lustre-devel] [PATCH SET 6: 0/2] staging: lustre: two
 miscellaneous patches
Message-ID: <151363798156.11899.768707943431676479.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

I thought I had mode one-off patches but this, but
it seems there are only two ready to go now.
The first removes another local interface in favour of a more general
interface, the second removing a warning (which actually say "BUG:").

Thanks,
NeilBrown


---

NeilBrown (2):
      staging: lustre: use strim instead of cfs_trimwhite.
      staging: lustre: disable preempt while sampling processor id.


 .../lustre/include/linux/libcfs/libcfs_string.h    |    1 -
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   20 -------------------
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   21 ++++++++++----------
 drivers/staging/lustre/lnet/lnet/config.c          |   10 +++++-----
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 +-
 5 files changed, 17 insertions(+), 37 deletions(-)

--
Signature
