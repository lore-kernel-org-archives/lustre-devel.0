From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:31:00 -0500
Subject: [lustre-devel] [PATCH 30/35] staging: lustre: llite:
	ll_write_begin/end not passing on errors
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Hiroya Nozaki <nozaki.hiroya@jp.fujitsu.com>, James Simmons <jsimmons@infradead.org>

From: Hiroya Nozaki <nozaki.hiroya@jp.fujitsu.com>

Because of a implementation of generic_perform_write(), write(2)
may return 0 with no errno even if EDQUOT or ENOSPC actually
happened in it. This patch fixes the issue with setting a proper
errno to ci_result.

Signed-off-by: Hiroya Nozaki <nozaki.hiroya@jp.fujitsu.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6732
Reviewed-on: http://review.whamcloud.com/15302
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw26.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index ca45b44..c1b7409 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -478,6 +478,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 
 	lcc = ll_cl_find(file);
 	if (!lcc) {
+		io = NULL;
 		result = -EIO;
 		goto out;
 	}
@@ -558,6 +559,8 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 			lu_ref_del(&page->cp_reference, "cl_io", io);
 			cl_page_put(env, page);
 		}
+		if (io)
+			io->ci_result = result;
 	} else {
 		*pagep = vmpage;
 		*fsdata = lcc;
@@ -627,6 +630,8 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 	    file->f_flags & O_SYNC || IS_SYNC(file_inode(file)))
 		result = vvp_io_write_commit(env, io);
 
+	if (result < 0)
+		io->ci_result = result;
 	return result >= 0 ? copied : result;
 }
 
-- 
1.7.1
