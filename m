From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:49:58 -0500
Subject: [lustre-devel] [PATCH 10/25] staging/lustre: F_SETLKW64 F_SETLK64
	F_GETLK64 are always defined
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-11-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Remove the ifdefs for the around usage.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/file.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 477dc0e..2e30c52 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2746,21 +2746,15 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 
 	switch (cmd) {
 	case F_SETLKW:
-#ifdef F_SETLKW64
 	case F_SETLKW64:
-#endif
 		flags = 0;
 		break;
 	case F_SETLK:
-#ifdef F_SETLK64
 	case F_SETLK64:
-#endif
 		flags = LDLM_FL_BLOCK_NOWAIT;
 		break;
 	case F_GETLK:
-#ifdef F_GETLK64
 	case F_GETLK64:
-#endif
 		flags = LDLM_FL_TEST_LOCK;
 		/* Save the old mode so that if the mode in the lock changes we
 		 * can decrement the appropriate reader or writer refcount.
-- 
2.1.0
