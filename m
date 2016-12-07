From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  7 Dec 2016 17:41:29 -0500
Subject: [lustre-devel] [PATCH 3/8] staging/lustre/llite: mark ll_io_init()
	static
In-Reply-To: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
References: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1481150494-1853127-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

It's not used anywhere out of this file.
Highlighted by sparse.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index f634c11..d93f06a 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1016,7 +1016,7 @@ static bool file_is_noatime(const struct file *file)
 	return false;
 }
 
-void ll_io_init(struct cl_io *io, const struct file *file, int write)
+static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 {
 	struct inode *inode = file_inode(file);
 
-- 
2.7.4
