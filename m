From: James Simmons <jsimmons@infradead.org>
Date: Mon, 11 Jul 2016 13:18:21 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: iov fixes for
	kiblnd_send
Message-ID: <1468257501-20630-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@ZenIV.linux.org.uk>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

With the move to iov_iter handling two issues merged
for the ko2iblnd driver. The first fix address a simple
typo of the wrong flag being used with iov_iter_kvec.
The second fix adds the payload offset to the payload
size.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 3d597dc..437e149 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1519,12 +1519,15 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	/* payload is either all vaddrs or all pages */
 	LASSERT(!(payload_kiov && payload_iov));
 
-	if (payload_kiov)
+	if (payload_kiov) {
 		iov_iter_bvec(&from, ITER_BVEC | WRITE,
-				payload_kiov, payload_niov, payload_nob);
-	else
-		iov_iter_kvec(&from, ITER_BVEC | WRITE,
-				payload_iov, payload_niov, payload_nob);
+			      payload_kiov, payload_niov,
+			      payload_nob + payload_offset);
+	} else {
+		iov_iter_kvec(&from, ITER_KVEC | WRITE,
+			      payload_iov, payload_niov,
+			      payload_nob + payload_offset);
+	}
 	iov_iter_advance(&from, payload_offset);
 
 	switch (type) {
-- 
2.7.4
