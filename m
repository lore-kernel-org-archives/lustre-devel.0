From: Luis de Bethencourt <luisbg@kernel.org>
Date: Wed,  6 Dec 2017 19:16:58 +0000
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: llite: Remove else
 after goto
Message-ID: <20171206191700.26532-1-luisbg@kernel.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Lai Siyao <lai.siyao@intel.com>, Ernestas Kulik <ernestas.kulik@gmail.com>, Aastha Gupta <aastha.gupta4104@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Luis de Bethencourt <luisbg@kernel.org>

If an "if" branch is terminated by a "goto", there's no need to have an
"else" statement and an indented block of code.

Remove the "else" statement to simplify the code flow.

Signed-off-by: Luis de Bethencourt <luisbg@kernel.org>
---

Hi,

The following patches remove unneeded 'else' after a 'goto' or 'return'.
They are meant to just make the code more readable and aren't functional
changes.

Thanks,
Luis

 drivers/staging/lustre/lustre/llite/dir.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 5b2e47c246f3..f5b67a4923e3 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1339,9 +1339,9 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 					       cmd == LL_IOC_MDC_GETINFO)) {
 				rc = 0;
 				goto skip_lmm;
-			} else {
-				goto out_req;
 			}
+
+			goto out_req;
 		}
 
 		if (cmd == IOC_MDC_GETFILESTRIPE ||
-- 
2.15.1
