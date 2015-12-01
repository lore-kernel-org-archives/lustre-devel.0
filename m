From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Date: Tue,  1 Dec 2015 17:05:13 -0500
Subject: [lustre-devel] [lustre cleanups 0/6] Patch series to make lustre
	safe(r) for W=1 compiles
Message-ID: <1449007519-73974-1-git-send-email-Valdis.Kletnieks@vt.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Start of a batch series to clean up the Lustre tree. Other people have
done  some sparse and checkpatch cleanups, but I found a bunch of
stuff building with W=1.

Valdis Kletnieks (6):

  Swap inline/const to kill 272 warnings
  Fix set-but-unused whinge.
  Clean up another C warnining:
  Fix another C compiler whine:
  Nuke an unsigned >= 0 assert
  Nuke another unsigned >= 0 assert

 drivers/staging/lustre/lustre/fid/lproc_fid.c      |  1 +
 drivers/staging/lustre/lustre/include/lu_object.h  |  2 +-
 drivers/staging/lustre/lustre/include/lustre_cfg.h |  4 --
 drivers/staging/lustre/lustre/libcfs/module.c      | 15 ++++----
 drivers/staging/lustre/lustre/llite/rw.c           |  1 -
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  1 -
 7 files changed, 26 insertions(+), 41 deletions(-)

-- 
2.6.3
