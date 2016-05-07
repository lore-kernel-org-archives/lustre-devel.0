From: James Simmons <jsimmons@infradead.org>
Date: Fri,  6 May 2016 21:30:30 -0400
Subject: [lustre-devel] [PATCH 09/10] staging: lustre: o2iblnd: properly set
	ibr_why
In-Reply-To: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
References: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462584631-5388-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

For the case of when the connections supported fragment count
is smaller than what is supported locally only set ibr_why to
IBLND_REJECT_RDMA_FRAGS if the ko2iblnd protocol verison is
IBLND_MSG_VERSION.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7101
Reviewed-on: http://review.whamcloud.com/16367
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index c4daf95..0f7e3a1 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2368,7 +2368,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		      reqmsg->ibm_u.connparams.ibcp_max_frags,
 		      kiblnd_rdma_frags(version, ni));
 
-		if (version >= IBLND_MSG_VERSION)
+		if (version == IBLND_MSG_VERSION)
 			rej.ibr_why = IBLND_REJECT_RDMA_FRAGS;
 
 		goto failed;
-- 
1.7.1
