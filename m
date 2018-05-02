From: Doug Oucharek <dougso@me.com>
Date: Tue, 01 May 2018 22:22:19 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: fix race at
 kiblnd_connect_peer
Message-ID: <1525238539-12482-1-git-send-email-dougso@me.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucahrek <dougso@me.com>, Alexander Boyko <alexander.boyko@seagate.com>

From: Doug Oucahrek <dougso@me.com>

cmid will be destroyed at OFED if kiblnd_cm_callback return error.
if error happen before the end of kiblnd_connect_peer, it will touch
destroyed cmid and fail as
(o2iblnd_cb.c:1315:kiblnd_connect_peer())
            ASSERTION( cmid->device != ((void *)0) ) failed:

Signed-off-by: Alexander Boyko <alexander.boyko@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10015
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Doug Oucharek <dougso@me.com>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index b4a182d..a76c1f2 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1290,11 +1290,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		goto failed2;
 	}
 
-	LASSERT(cmid->device);
-	CDEBUG(D_NET, "%s: connection bound to %s:%pI4h:%s\n",
-	       libcfs_nid2str(peer->ibp_nid), dev->ibd_ifname,
-	       &dev->ibd_ifip, cmid->device->name);
-
 	return;
 
  failed2:
@@ -2996,8 +2991,19 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		} else {
 			rc = rdma_resolve_route(
 				cmid, *kiblnd_tunables.kib_timeout * 1000);
-			if (!rc)
+			if (!rc) {
+				struct kib_net *net = peer->ibp_ni->ni_data;
+				struct kib_dev *dev = net->ibn_dev;
+
+				CDEBUG(D_NET, "%s: connection bound to "\
+				       "%s:%pI4h:%s\n",
+				       libcfs_nid2str(peer->ibp_nid),
+				       dev->ibd_ifname,
+				       &dev->ibd_ifip, cmid->device->name);
+
 				return 0;
+			}
+
 			/* Can't initiate route resolution */
 			CERROR("Can't resolve route for %s: %d\n",
 			       libcfs_nid2str(peer->ibp_nid), rc);
-- 
1.8.3.1
