From: James Simmons <jsimmons@infradead.org>
Date: Thu,  9 Jun 2016 18:45:45 -0400
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: lnet: Don't access NULL
	NI on failure path
In-Reply-To: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
References: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1465512347-11650-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucharek <doug.s.oucharek@intel.com>

From: Doug Oucharek <doug.s.oucharek@intel.com>

In kiblnd_passive_connect(), if we are failing the connection
attempt because we cannot find a valid NI (we have a NULL NI),
we were coring after the "goto fail" because the failure
path was assuming non-NULL NI.

This patch ensures we don't dereference a NULL NI on that
failure path.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8022
Reviewed-on: http://review.whamcloud.com/19614
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Matt Ezell <ezellma@ornl.gov>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 0f7e3a1..dbc26f1 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2529,12 +2529,13 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	return 0;
 
  failed:
-	if (ni)
+	if (ni) {
 		lnet_ni_decref(ni);
+		rej.ibr_cp.ibcp_queue_depth = kiblnd_msg_queue_size(version, ni);
+		rej.ibr_cp.ibcp_max_frags = kiblnd_rdma_frags(version, ni);
+	}
 
 	rej.ibr_version             = version;
-	rej.ibr_cp.ibcp_queue_depth = kiblnd_msg_queue_size(version, ni);
-	rej.ibr_cp.ibcp_max_frags = kiblnd_rdma_frags(version, ni);
 	kiblnd_reject(cmid, &rej);
 
 	return -ECONNREFUSED;
-- 
1.7.1
