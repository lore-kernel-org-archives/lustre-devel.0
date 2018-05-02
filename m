From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 May 2018 14:21:44 -0400
Subject: [lustre-devel] [PATCH 0/4] staging: lustre: obdclass: missing
 lu_object fixes
Message-ID: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Lai Siyao <lai.siyao@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

With the work going for lu_object by Neil I noticed him solving the
same problem as the Intel developers in a very similar approach. Also
with the changes we don't want to lose these important changes. This
is more mean for a basic review since in the end Neil and this work
will be combined in some fashion. Note this patch set is based on
top of Neil's cleanup patches for lu_objects published a few days ago.

Hongchao Zhang (1):
  staging: lustre: obdclass: guarantee all keys filled

John L. Hammond (1):
  staging: lustre: obdclass: hoist locking in lu_context_exit()

Lai Siyao (1):
  staging: lustre: obdclass: change object lookup to no wait mode

Li Xi (1):
  staging: lustre: obdclass: change spinlock of key to rwlock

 drivers/staging/lustre/lustre/include/lu_object.h  |   2 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 153 +++++++++++----------
 2 files changed, 83 insertions(+), 72 deletions(-)

-- 
1.8.3.1
