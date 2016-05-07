From: James Simmons <jsimmons@infradead.org>
Date: Fri,  6 May 2016 21:30:29 -0400
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: o2iblnd: remove last
	of kiblnd_tunables_fini
In-Reply-To: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
References: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462584631-5388-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

The function kibnd_tunables_fini() no longer exist. Remove
it from o2iblnd.h

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7101
Reviewed-on: http://review.whamcloud.com/16367
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index d458773..b22984f 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -995,7 +995,6 @@ void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status);
 
 int kiblnd_tunables_setup(struct lnet_ni *ni);
 void kiblnd_tunables_init(void);
-void kiblnd_tunables_fini(void);
 
 int  kiblnd_connd(void *arg);
 int  kiblnd_scheduler(void *arg);
-- 
1.7.1
