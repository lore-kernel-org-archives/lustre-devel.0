From: Tabrez khan <khan.tabrez21@gmail.com>
Date: Fri, 16 Dec 2016 19:59:31 +0530
Subject: [lustre-devel] [PATCH] staging : lustre : Remove braces from
	single-line body.
Message-ID: <1481898571-16842-1-git-send-email-khan.tabrez21@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: andreas.dilger@intel.com, jsimmons@infradead.org
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Remove unnecessary braces {} for single while statement.
This warning is found using checkpatch.pl.

Signed-off-by: Tabrez khan <khan.tabrez21@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/cl_io.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index bc4b7b6..2daede8 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -1371,9 +1371,9 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 	LASSERT(atomic_read(&anchor->csi_sync_nr) == 0);
 
 	/* wait until cl_sync_io_note() has done wakeup */
-	while (unlikely(atomic_read(&anchor->csi_barrier) != 0)) {
+	while (unlikely(atomic_read(&anchor->csi_barrier) != 0))
 		cpu_relax();
-	}
+
 
 	return rc;
 }
-- 
2.7.4
