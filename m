From: Dmitriy Cherkasov <dmitriy@oss-tech.org>
Date: Fri, 28 Jul 2017 17:13:43 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: lov: remove dead code
Message-ID: <1501287223-18570-1-git-send-email-dmitriy@oss-tech.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitriy Cherkasov <dmitriy@oss-tech.org>

This #if 0 block has been commented out for years. Assume it is not
needed and remove it.

Signed-off-by: Dmitriy Cherkasov <dmitriy@oss-tech.org>
---
 drivers/staging/lustre/lustre/lov/lov_io.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index babf39a..0fb5723 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -939,12 +939,6 @@ static void lov_empty_impossible(const struct lu_env *env,
 	.op = {
 		[CIT_READ] = {
 			.cio_fini       = lov_empty_io_fini,
-#if 0
-			.cio_iter_init  = LOV_EMPTY_IMPOSSIBLE,
-			.cio_lock       = LOV_EMPTY_IMPOSSIBLE,
-			.cio_start      = LOV_EMPTY_IMPOSSIBLE,
-			.cio_end	= LOV_EMPTY_IMPOSSIBLE
-#endif
 		},
 		[CIT_WRITE] = {
 			.cio_fini      = lov_empty_io_fini,
-- 
1.9.1
