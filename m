From: Anson Jacob <ansonjacob.aj@gmail.com>
Date: Tue, 16 Aug 2016 15:20:00 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: fix checkpatch error
Message-ID: <20160816192000.GA660@X250>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, oleg.drokin@intel.com, andreas.dilger@intel.com, lustre-devel@lists.lustre.org
Cc: Kernel List <linux-kernel@vger.kernel.org>, Staging List <devel@driverdev.osuosl.org>

convert spaces to tab

fix the following error messages from checkpatch.pl

ERROR: code indent should use tabs where possible
WARNING: please, no spaces at the start of a line

Signed-off-by: Anson Jacob <ansonjacob.aj@gmail.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 3cd4a25..80c13c9 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2354,7 +2354,7 @@ struct cl_client_cache {
 	 * Waitq for awaiting unstable pages to reach zero.
 	 * Used at umounting time and signaled on BRW commit
 	 */
-        wait_queue_head_t	ccc_unstable_waitq;
+	wait_queue_head_t	ccc_unstable_waitq;
 
 };
 
-- 
2.7.4
