From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:18 -0500
Subject: [lustre-devel] [PATCH 40/56] staging/lustre: Remove unused
	lli_open_count from struct ll_inode_info
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-41-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Capabilities code was the only user and it is long gone.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/llite_internal.h | 6 ++----
 drivers/staging/lustre/lustre/llite/llite_lib.c      | 1 -
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 46144ff..bbd5ab8f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -133,10 +133,8 @@ struct ll_inode_info {
 	 * for allocating OST objects after a mknod() and later open-by-FID. */
 	struct lu_fid		   lli_pfid;
 
-	struct list_head		      lli_close_list;
-	/* open count currently used by capability only, indicate whether
-	 * capability needs renewal */
-	atomic_t		    lli_open_count;
+	struct list_head	      lli_close_list;
+
 	unsigned long		      lli_rmtperm_time;
 
 	/* handle is to be sent to MDS later on done_writing and setattr.
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 67b4b80..b652aee 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -797,7 +797,6 @@ void ll_lli_init(struct ll_inode_info *lli)
 	/* Do not set lli_fid, it has been initialized already. */
 	fid_zero(&lli->lli_pfid);
 	INIT_LIST_HEAD(&lli->lli_close_list);
-	atomic_set(&lli->lli_open_count, 0);
 	lli->lli_rmtperm_time = 0;
 	lli->lli_pending_och = NULL;
 	lli->lli_mds_read_och = NULL;
-- 
2.1.0
