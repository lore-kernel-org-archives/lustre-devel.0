From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:30 -0400
Subject: [lustre-devel] [PATCH 77/80] staging: lustre: lnet: Correct
	position of lnet_ni_decref()
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-78-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucharek <doug.s.oucharek@intel.com>, James Simmons <jsimmons@infradead.org>

From: Doug Oucharek <doug.s.oucharek@intel.com>

In fix http://review.whamcloud.com/#/c/19614/, the call
to lnet_ni_decref() should have followed the routines
which are using the NI.  This patch correct that.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8022
Reviewed-on: http://review.whamcloud.com/21001
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 9eb1db6..19c90fc 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2526,9 +2526,9 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 
  failed:
 	if (ni) {
-		lnet_ni_decref(ni);
 		rej.ibr_cp.ibcp_queue_depth = kiblnd_msg_queue_size(version, ni);
 		rej.ibr_cp.ibcp_max_frags = kiblnd_rdma_frags(version, ni);
+		lnet_ni_decref(ni);
 	}
 
 	rej.ibr_version             = version;
-- 
1.7.1
