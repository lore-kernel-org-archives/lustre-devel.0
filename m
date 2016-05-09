From: James Simmons <jsimmons@infradead.org>
Date: Mon,  9 May 2016 10:53:46 -0400
Subject: [lustre-devel] [PATCH 2/4] staging: lustre: o2iblnd: make
	rdma_create_id() support containers
In-Reply-To: <1462805628-23403-1-git-send-email-jsimmons@infradead.org>
References: <1462805628-23403-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462805628-23403-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Li Dongyang <dongyang.li@anu.edu.au>, James Simmons <jsimmons@infradead.org>

From: Li Dongyang <dongyang.li@anu.edu.au>

Add support for lustre's ko2iblnd driver to work with
containers which was requested by Sebastien Buisson.

Signed-off-by: Li Dongyang <dongyang.li@anu.edu.au>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6215
Reviewed-on: http://review.whamcloud.com/18759
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index b22984f..45bbe93 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -109,7 +109,7 @@ extern kib_tunables_t  kiblnd_tunables;
 					IBLND_CREDIT_HIGHWATER_V1 : \
 					t->lnd_peercredits_hiw)
 
-#define kiblnd_rdma_create_id(cb, dev, ps, qpt) rdma_create_id(&init_net, \
+#define kiblnd_rdma_create_id(cb, dev, ps, qpt) rdma_create_id(current->nsproxy->net_ns, \
 							       cb, dev, \
 							       ps, qpt)
 
-- 
1.7.1
