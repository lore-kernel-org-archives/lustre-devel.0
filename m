From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  2 Nov 2016 21:25:00 -0400
Subject: [lustre-devel] [PATCH 10/14] staging/lustre/llite: protect from
	accessing NULL lli_clob
In-Reply-To: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1478136304-867780-11-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Bobi Jam <bobijam.xu@intel.com>

Need to check file's lli_clob object before calling
lov_read_and_clear_async_rc().

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Reviewed-on: http://review.whamcloud.com/23031
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8682
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/file.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index c1c7551..7886840 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2328,9 +2328,11 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 		lli->lli_async_rc = 0;
 		if (rc == 0)
 			rc = err;
-		err = lov_read_and_clear_async_rc(lli->lli_clob);
-		if (rc == 0)
-			rc = err;
+		if (lli->lli_clob) {
+			err = lov_read_and_clear_async_rc(lli->lli_clob);
+			if (rc == 0)
+				rc = err;
+		}
 	}
 
 	err = md_sync(ll_i2sbi(inode)->ll_md_exp, ll_inode2fid(inode), &req);
-- 
2.7.4
