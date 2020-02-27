From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:44 -0500
Subject: [lustre-devel] [PATCH 476/622] lustre: llite: Improve readahead RPC
 issuance
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-477-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

lov_io_submit receives a range of pages, then adds pages in
to a batch until it hits a page which is not in the stripe
associated with this lov object.  This means that if a
readahead page range hits the same stripe more than once,
we will issue multiple I/Os, even if the pages would fit in
one RPC.

This is unnecessary - Just submit all these pages at once.

mpirun -n 2 $IOR -s 2000 -t 47K -b 47K -k -r -E -o $FILE

Without patch:
osc.lustre-OST0001-osc-ffff8fe82c952000.rpc_stats=

                        read                    write
pages per rpc         rpcs   % cum % |       rpcs   % cum %
1:                     118  56  56   |          0   0   0
2:                       0   0  56   |          0   0   0
4:                       0   0  56   |          0   0   0
8:                       0   0  56   |          0   0   0
16:                      5   2  58   |          0   0   0
32:                      0   0  58   |          0   0   0
64:                      0   0  58   |          0   0   0
128:                    21  10  68   |          0   0   0
256:                    25  11  80   |          0   0   0
512:                    10   4  85   |          0   0   0
1024:                   31  14 100   |          0   0   0

osc.lustre-OST0002-osc-ffff8fe82c952000.rpc_stats=
                        read                    write
pages per rpc         rpcs   % cum % |       rpcs   % cum %
1:                       5   6   6   |          0   0   0
2:                       0   0   6   |          0   0   0
4:                       0   0   6   |          0   0   0
8:                       0   0   6   |          0   0   0
16:                      0   0   6   |          0   0   0
32:                      0   0   6   |          0   0   0
64:                      0   0   6   |          0   0   0
128:                    19  23  29   |          0   0   0
256:                    19  23  52   |          0   0   0
512:                     5   6  58   |          0   0   0
1024:                   34  41 100   |          0   0   0

With patch:
osc.lustre-OST0001-osc-ffff8fe7a7227800.rpc_stats=
                        read                    write
pages per rpc         rpcs   % cum % |       rpcs   % cum %
1:                      12  17  17   |          0   0   0
2:                       0   0  17   |          0   0   0
4:                       0   0  17   |          0   0   0
8:                       0   0  17   |          0   0   0
16:                      5   7  24   |          0   0   0
32:                      0   0  24   |          0   0   0
64:                      5   7  31   |          0   0   0
128:                     6   8  40   |          0   0   0
256:                     1   1  42   |          0   0   0
512:                     2   2  44   |          0   0   0
1024:                   38  55 100   |          0   0   0

osc.lustre-OST0002-osc-ffff8fe7a7227800.rpc_stats=
                        read                    write
pages per rpc         rpcs   % cum % |       rpcs   % cum %
1:                       0   0   0   |          0   0   0
2:                       0   0   0   |          0   0   0
4:                       0   0   0   |          0   0   0
8:                       0   0   0   |          0   0   0
16:                      0   0   0   |          0   0   0
32:                      0   0   0   |          0   0   0
64:                      4   7   7   |          0   0   0
128:                     7  13  21   |          0   0   0
256:                     0   0  21   |          0   0   0
512:                     3   5  26   |          0   0   0
1024:                   38  73 100   |          0   0   0

Note the much larger # of smaller RPC issued without the patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12533
Lustre-commit: 05b9da4fd124 ("LU-12533 llite: Improve readahead RPC issuance")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35458
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_io.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 6e86efa..fbed3de 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -1081,6 +1081,7 @@ static int lov_io_submit(const struct lu_env *env,
 	struct lov_io_sub *sub;
 	struct cl_page_list *plist = &lov_env_info(env)->lti_plist;
 	struct cl_page *page;
+	struct cl_page *tmp;
 	int index;
 	int rc = 0;
 
@@ -1105,10 +1106,10 @@ static int lov_io_submit(const struct lu_env *env,
 		cl_page_list_move(&cl2q->c2_qin, qin, page);
 
 		index = lov_page_index(page);
-		while (qin->pl_nr > 0) {
-			page = cl_page_list_first(qin);
+		cl_page_list_for_each_safe(page, tmp, qin) {
+			/* this page is not on this stripe */
 			if (index != lov_page_index(page))
-				break;
+				continue;
 
 			cl_page_list_move(&cl2q->c2_qin, qin, page);
 		}
-- 
1.8.3.1
