From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 18:53:27 -0500
Subject: [lustre-devel] [PATCH 4/7] staging: lustre: Change connect peer
	failed cleanup order
In-Reply-To: <1456962810-21806-1-git-send-email-jsimmons@infradead.org>
References: <1456962810-21806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456962810-21806-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucharek <doug.s.oucharek@intel.com>

From: Doug Oucharek <doug.s.oucharek@intel.com>

A race condition has been found where connd is cleaning up failed
connections, the peer ref counter goes to zero, but we stil have
a connecting counter > 0.

One possible race is when we are retrying a connection by
calling kiblnd_connect_peer() which itself fails and decrements
the peer ref counter and gets swapped out before it can decrement
the connecting counter.  connd swaps in and cleans up the
connection where it sees a peer ref counter of 1 and a connecting
counter of 1.  This will trigger the assert seen in LU-7210 when
it decrements the peer counter.

The solution: be sure to decrement the connecting counter
before decrementing the peer counter in the peer connect
failure path.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7210
Reviewed-on: http://review.whamcloud.com/17004
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index f76c570..7602d71 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1298,8 +1298,10 @@ kiblnd_connect_peer(kib_peer_t *peer)
 	return;
 
  failed2:
+	kiblnd_peer_connect_failed(peer, 1, rc);
 	kiblnd_peer_decref(peer);	       /* cmid's ref */
 	rdma_destroy_id(cmid);
+	return;
  failed:
 	kiblnd_peer_connect_failed(peer, 1, rc);
 }
-- 
1.7.1
