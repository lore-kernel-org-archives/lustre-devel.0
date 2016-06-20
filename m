From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:36 -0400
Subject: [lustre-devel] [PATCH 21/28] staging/lustre/o2ib: Don't access NULL
	NI on failure path
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-22-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucharek <doug.s.oucharek@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Doug Oucharek <doug.s.oucharek@intel.com>

In kiblnd_passive_connect(), if we are failing the connection
attempt because we cannot find a valid NI (we have a NULL NI),
we were coring after the "goto fail" because the failure
path was assuming non-NULL NI.

This patch ensures we don't dereference a NULL NI on that
failure path.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-on: http://review.whamcloud.com/19614
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8022
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Matt Ezell <ezellma@ornl.gov>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index e32e43b..a585d22 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2525,12 +2525,14 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	return 0;
 
  failed:
-	if (ni)
+	if (ni) {
 		lnet_ni_decref(ni);
+		rej.ibr_cp.ibcp_queue_depth =
+			kiblnd_msg_queue_size(version, ni);
+		rej.ibr_cp.ibcp_max_frags = kiblnd_rdma_frags(version, ni);
+	}
 
 	rej.ibr_version             = version;
-	rej.ibr_cp.ibcp_queue_depth = kiblnd_msg_queue_size(version, ni);
-	rej.ibr_cp.ibcp_max_frags = kiblnd_rdma_frags(version, ni);
 	kiblnd_reject(cmid, &rej);
 
 	return -ECONNREFUSED;
-- 
2.7.4
