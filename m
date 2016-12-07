From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  7 Dec 2016 00:39:27 -0500
Subject: [lustre-devel] [PATCH] staging/lustre/lnetselftest: Fix potential
	integer overflow
Message-ID: <1481089167-1674826-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

It looks like if the passed in parameter is not present, but
parameter length is non zero, then sanity checks on the length
are skipped and lstcon_test_add() might then use incorrect
allocation that's prone to integer overflow size.

This patch ensures that parameter len is zero if parameter is
not present.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lnet/selftest/conctl.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 02847bf..9438302 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -742,6 +742,10 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 	     PAGE_SIZE - sizeof(struct lstcon_test)))
 		return -EINVAL;
 
+	/* Enforce zero parameter length if there's no parameter */
+	if (!args->lstio_tes_param && args->lstio_tes_param_len)
+		return -EINVAL;
+
 	LIBCFS_ALLOC(batch_name, args->lstio_tes_bat_nmlen + 1);
 	if (!batch_name)
 		return rc;
-- 
2.7.4
