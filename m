From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:15 -0400
Subject: [lustre-devel] [PATCH 38/45] lnet: remove lnet_extract_iov()
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-39-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The only place this is called, the src kvec is
NULL with length 0, so it returns 0.
So remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13004
Lustre-commit: 571943f9cd090 ("LU-13004 lnet: remove lnet_extract_iov()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37848
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  4 ----
 net/lnet/lnet/lib-move.c      | 49 -------------------------------------------
 2 files changed, 53 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 01e8489..a4a323c 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -614,10 +614,6 @@ int lnet_delay_rule_list(int pos, struct lnet_fault_attr *attr,
 void lnet_counters_reset(void);
 
 unsigned int lnet_iov_nob(unsigned int niov, struct kvec *iov);
-int lnet_extract_iov(int dst_niov, struct kvec *dst,
-		     int src_niov, const struct kvec *src,
-		     unsigned int offset, unsigned int len);
-
 unsigned int lnet_kiov_nob(unsigned int niov, struct bio_vec *iov);
 int lnet_extract_kiov(int dst_niov, struct bio_vec *dst,
 		      int src_niov, const struct bio_vec *src,
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index cf134b5..51b8191 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -364,55 +364,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 EXPORT_SYMBOL(lnet_copy_kiov2iter);
 
-int
-lnet_extract_iov(int dst_niov, struct kvec *dst,
-		 int src_niov, const struct kvec *src,
-		 unsigned int offset, unsigned int len)
-{
-	/*
-	 * Initialise 'dst' to the subset of 'src' starting at 'offset',
-	 * for exactly 'len' bytes, and return the number of entries.
-	 * NB not destructive to 'src'
-	 */
-	unsigned int frag_len;
-	unsigned int niov;
-
-	if (!len)			/* no data => */
-		return 0;		/* no frags */
-
-	LASSERT(src_niov > 0);
-	while (offset >= src->iov_len) {	/* skip initial frags */
-		offset -= src->iov_len;
-		src_niov--;
-		src++;
-		LASSERT(src_niov > 0);
-	}
-
-	niov = 1;
-	for (;;) {
-		LASSERT(src_niov > 0);
-		LASSERT((int)niov <= dst_niov);
-
-		frag_len = src->iov_len - offset;
-		dst->iov_base = ((char *)src->iov_base) + offset;
-
-		if (len <= frag_len) {
-			dst->iov_len = len;
-			return niov;
-		}
-
-		dst->iov_len = frag_len;
-
-		len -= frag_len;
-		dst++;
-		src++;
-		niov++;
-		src_niov--;
-		offset = 0;
-	}
-}
-EXPORT_SYMBOL(lnet_extract_iov);
-
 unsigned int
 lnet_kiov_nob(unsigned int niov, struct bio_vec *kiov)
 {
-- 
1.8.3.1
