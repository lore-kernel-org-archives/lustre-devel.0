From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:24 -0500
Subject: [lustre-devel] [PATCH 276/622] lustre: llite,
 readahead: fix to call ll_ras_enter() properly
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-277-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

ll_ras_enter() is expected to be called per syscall.
However, with fast read enabled, it will be no longer true that
We will call vvp_io_read_start() for every syscall.

To fix this problem, we should move this to file read handler.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12043
Lustre-commit: 500edcada7e4 ("LU-12043 llite, readahead: fix to call ll_ras_enter() properly")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/34755
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c   | 2 ++
 fs/lustre/llite/vvp_io.c | 1 -
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 61d53c4..d059ac7 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1625,6 +1625,8 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	u16 refcheck;
 	ssize_t rc2;
 
+	ll_ras_enter(iocb->ki_filp);
+
 	result = ll_do_fast_read(iocb, to);
 	if (result < 0 || iov_iter_count(to) == 0)
 		goto out;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 43f4088..1f82fe6 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -773,7 +773,6 @@ static int vvp_io_read_start(const struct lu_env *env,
 		vio->vui_ra_valid = true;
 		vio->vui_ra_start = cl_index(obj, pos);
 		vio->vui_ra_count = cl_index(obj, tot + PAGE_SIZE - 1);
-		ll_ras_enter(file);
 	}
 
 	/* BUG: 5972 */
-- 
1.8.3.1
