From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Feb 2016 10:25:51 -0500
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: do not memset after
	LIBCFS_ALLOC
In-Reply-To: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
References: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455549954-29532-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Frank Zago <fzago@cray.com>

From: Frank Zago <fzago@cray.com>

LIBCFS_ALLOC already zero out the memory allocated, so there is no
need to zero out the memory again.

Signed-off-by: Frank Zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5304
Reviewed-on: http://review.whamcloud.com/11012
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 2e7b5ca..98570b3 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -339,8 +339,6 @@ int kiblnd_create_peer(lnet_ni_t *ni, kib_peer_t **peerp, lnet_nid_t nid)
 		return -ENOMEM;
 	}
 
-	memset(peer, 0, sizeof(*peer));	 /* zero flags etc */
-
 	peer->ibp_ni = ni;
 	peer->ibp_nid = nid;
 	peer->ibp_error = 0;
-- 
1.7.1
