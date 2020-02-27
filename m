From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:01 -0500
Subject: [lustre-devel] [PATCH 373/622] lustre: llite: fix deadloop with
 tiny write
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-374-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

For a small write(<4K), we will use tiny write and
__generic_file_write_iter() will be called to handle it.

On newer kernel(4.14 etc), the function is exported and will
do something like following:

|->__generic_file_write_iter
  |->generic_perform_write()

If iov_iter_count() passed in is 0, generic_write_perform() will
try go to forever loop as bytes copied is always calculated as 0.

The problem is VFS doesn't always skip IO count zero before it comes
to lower layer read/write hook, and we should do it by ourselves.

To fix this problem, always return 0 early if there is no
real any IO needed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12382
Lustre-commit: e9a543b0d303 ("LU-12382 llite: fix deadloop with tiny write")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/35058
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 5d1cfa4..1ed4b14 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1668,6 +1668,9 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	ssize_t rc2;
 	bool cached;
 
+	if (!iov_iter_count(to))
+		return 0;
+
 	/**
 	 * Currently when PCC read failed, we do not fall back to the
 	 * normal read path, just return the error.
@@ -1778,6 +1781,11 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	bool cached;
 	int result;
 
+	if (!iov_iter_count(from)) {
+		rc_normal = 0;
+		goto out;
+	}
+
 	/**
 	 * When PCC write failed, we usually do not fall back to the normal
 	 * write path, just return the error. But there is a special case when
-- 
1.8.3.1
