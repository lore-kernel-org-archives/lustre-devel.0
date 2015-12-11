From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Date: Fri, 11 Dec 2015 18:04:19 -0500
Subject: [lustre-devel] [PATCH v2 0/6] Patch series to make lustre safe(r)
	for W=1 compiles
Message-ID: <1449875065-35182-1-git-send-email-Valdis.Kletnieks@vt.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Start of a batch series to clean up the Lustre tree. Other people have
done some sparse and checkpatch cleanups, but I found a bunch of
stuff building with W=1. There's probably more, but this was the
really low-hanging obvious fruit.

Valdis Kletnieks (6):
  staging/lustre: Silence warning about 'inline'
  staging/lustre: Fix set-but-unused whinge.
  staging/lustre: Clean up another C warnining: set but not used
  staging/lustre: Fix another C compiler whine: set but not used
  staging/lustre: Nuke an unsigned >= 0 assert
  staging/lustre: Nuke another unsigned >= 0 assert

 drivers/staging/lustre/lustre/fid/lproc_fid.c      |  1 +
 drivers/staging/lustre/lustre/include/lu_object.h  |  2 +-
 drivers/staging/lustre/lustre/include/lustre_cfg.h |  4 --
 drivers/staging/lustre/lustre/libcfs/module.c      | 15 ++++----
 drivers/staging/lustre/lustre/llite/rw.c           |  1 -
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  1 -
 6 files changed, 9 insertions(+), 15 deletions(-)

-- 
2.6.3
