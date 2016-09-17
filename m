From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sat, 17 Sep 2016 21:41:39 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: clean function declaration
	in super25.c up
Message-ID: <1474119699-4965-1-git-send-email-baoyou.xie@linaro.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, dmitry.eremin@intel.com, fzago@cray.com, shivanib134@gmail.com, bhumirks@gmail.com, mike.rapoport@gmail.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn

We get 1 warning when building kernel with W=1:
drivers/staging/lustre/lnet/selftest/conctl.c:804:1: warning: no previous prototype for 'lstcon_ioctl_entry' [-Wmissing-prototypes]

In fact, this function is declared in
drivers/staging/lustre/lustre/llite/super25.c, but should be
moved into a header file, thus can be recognized in other file.

So this patch moves the declaration into
drivers/staging/lustre/lnet/selftest/console.h

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/staging/lustre/lnet/selftest/console.c | 2 --
 drivers/staging/lustre/lnet/selftest/console.h | 1 +
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 4c33621..a0fcbf3 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1993,8 +1993,6 @@ static void lstcon_init_acceptor_service(void)
 	lstcon_acceptor_service.sv_wi_total = SFW_FRWK_WI_MAX;
 }
 
-extern int lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
-
 static DECLARE_IOCTL_HANDLER(lstcon_ioctl_handler, lstcon_ioctl_entry);
 
 /* initialize console */
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 78b1477..78388a6 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -184,6 +184,7 @@ lstcon_id2hash(lnet_process_id_t id, struct list_head *hash)
 	return &hash[idx];
 }
 
+int lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
 int lstcon_console_init(void);
 int lstcon_console_fini(void);
 int lstcon_session_match(lst_sid_t sid);
-- 
2.7.4
