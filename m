From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:24 -0400
Subject: [lustre-devel] [PATCH 125/151] lustre: llite: have ll_write_end to
 sync for DIO
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-126-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vladimir Saveliev <c17830@cray.com>

direct IO write uses buffered write for pages which could not be
released. If not adjacent pages are not releasable,
vio->u.write.vui_queue list becomes non-contiguos which makes
page_list_sanity_check() to fail.

Have ll_write_commit to do vvp_io_write_commit() when it is called in
course of direct IO.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10356
Cray-bug-id: MRP-4415
Lustre-commit: 6ea9171769db ("LU-10356 llite: have ll_write_end to sync for DIO")
Signed-off-by: Vladimir Saveliev <c17830@cray.com>
Reviewed-on: https://review.whamcloud.com/30659
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw26.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 2baab10..f5c1479 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -684,8 +684,7 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 		unplug = true;
 	}
 
-	if (unplug ||
-	    file->f_flags & O_SYNC || IS_SYNC(file_inode(file)))
+	if (unplug || io->u.ci_wr.wr_sync)
 		result = vvp_io_write_commit(env, io);
 
 	if (result < 0)
-- 
1.8.3.1
