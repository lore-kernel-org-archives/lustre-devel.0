From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 08:09:25 +1100
Subject: [lustre-devel] [PATCH 0/2] Two lustre bug fixes
Message-ID: <151846966702.17168.15765227765350491300.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

These patches fix 2 issues I found during testing.
Together they cause lots of path-name-lookup syscalls
to return -ENOMEM.
The first bug fixes triggers and error
The second bug fixes causes that error to be reported as -ENOMEM.

Thanks,
NeilBrown


---

NeilBrown (2):
      staging: lustre: fix inverted test on strcmp
      staging: lustre: honor error code from ll_iget().


 drivers/staging/lustre/lustre/include/lustre_lmv.h |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--
Signature
