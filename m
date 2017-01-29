From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:24 -0500
Subject: [lustre-devel] [PATCH 56/60] staging: lustre: llite: don't invoke
	direct_IO for the EOF case
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-57-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Yang Sheng <yang.sheng@intel.com>, James Simmons <jsimmons@infradead.org>

From: Yang Sheng <yang.sheng@intel.com>

The function generic_file_read_iter() does not check EOF
before invoke direct_IO callback. So we have to check it
ourselves.

Signed-off-by: Yang Sheng <yang.sheng@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8969
Reviewed-on: https://review.whamcloud.com/24552
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw26.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 21e06e5..d89e795 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -345,6 +345,10 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
 	ssize_t tot_bytes = 0, result = 0;
 	long size = MAX_DIO_SIZE;
 
+	/* Check EOF by ourselves */
+	if (iov_iter_rw(iter) == READ && file_offset >= i_size_read(inode))
+		return 0;
+
 	/* FIXME: io smaller than PAGE_SIZE is broken on ia64 ??? */
 	if ((file_offset & ~PAGE_MASK) || (count & ~PAGE_MASK))
 		return -EINVAL;
-- 
1.8.3.1
