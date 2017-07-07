From: Craig Inches <Craig@craiginches.com>
Date: Fri, 07 Jul 2017 01:46:26 +0000 (UTC)
Subject: [lustre-devel] [PATCH 0/4] Staging: Lustre Style Fixes
Message-ID: <cover.1499388016.git.Craig@craiginches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This series fixes a few style issues in lustre. All where picked up
by checkpatch. 

Craig Inches (4):
  Staging: Luster: Clean up line over 80Char in lib-lnet.h
  Staging: Lustre Fix up multiple Block Comments in lib-types.h
  Staging: Lustre Fixing multiline block comments in lnetst.h
  Staging: Lustre Fix block statement style issue

 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   3 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |  46 +++++---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 129 +++++++++++++--------
 .../staging/lustre/include/linux/lnet/socklnd.h    |   3 +-
 4 files changed, 115 insertions(+), 66 deletions(-)

-- 
2.13.0
