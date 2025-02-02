Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AE89CC02193
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:56:09 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMFK47JCz210Y;
	Sun, 02 Feb 2025 12:49:41 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMCT2PR6z20tj
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:48:05 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CBC6E18236B;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id C95EF106BE15; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:13 -0500
Message-ID: <20250202204633.1148872-14-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 13/33] lustre: cksum: fix generating T10PI
 guard tags for partial brw page
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Li Xi <lixi@ddn.com>, Li Dongyang <dongyangli@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Li Dongyang <dongyangli@ddn.com>

To get better performance, we allocate a page as the buffer for
T10PI guard tags, we fill the buffer going over every page for brw,
when the buffer is considered full, we use
cfs_crypto_hash_update_page() to update the hash and reuse the buffer.

It doesn't work when there's a page in the brw gets clipped, and the
checksum sector size is 512. For a page with PAGE_SIZE of 4096,
and offset at 1024, we will end up with 6 guard tags, and won't have
enough space in the very end of the buffer for a full brw page, which
needs 8.

Work out the number of guard tags for each page, update the
checksum hash and reuse the buffer when needed.

Fixes: 7c06498be70 ("lustre: osc: add T10PI support for RPC checksum")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16712
Lustre-commit: 3999627447c01eebd ("LU-16712 cksum: fix generating T10PI guard tags for partial brw page")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50540
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 44 +++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 061767503401..582cd96c304b 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1197,12 +1197,12 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 	struct page *__page;
 	unsigned char *buffer;
 	__be16 *guard_start;
-	unsigned int bufsize;
 	int guard_number;
 	int used_number = 0;
 	int used;
 	u32 cksum;
-	int rc = 0;
+	unsigned int bufsize = sizeof(cksum);
+	int rc = 0, rc2;
 	int i = 0;
 
 	LASSERT(pg_count > 0);
@@ -1228,6 +1228,15 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 
 	while (nob > 0 && pg_count > 0) {
 		unsigned int count = pga[i]->count > nob ? nob : pga[i]->count;
+		int off = pga[i]->off & ~PAGE_MASK;
+		int guards_needed = DIV_ROUND_UP(off + count, sector_size) -
+				    (off / sector_size);
+
+		if (guards_needed > guard_number - used_number) {
+			cfs_crypto_hash_update_page(hdesc, __page, 0,
+						    used_number * sizeof(*guard_start));
+			used_number = 0;
+		}
 
 		/* corrupt the data before we compute the checksum, to
 		 * simulate an OST->client data error
@@ -1235,7 +1244,6 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 		if (unlikely(i == 0 && opc == OST_READ &&
 			     OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_RECEIVE))) {
 			unsigned char *ptr = kmap(pga[i]->pg);
-			int off = pga[i]->off & ~PAGE_MASK;
 
 			memcpy(ptr + off, "bad1", min_t(typeof(nob), 4, nob));
 			kunmap(pga[i]->pg);
@@ -1262,34 +1270,32 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 			break;
 
 		used_number += used;
-		if (used_number == guard_number) {
-			cfs_crypto_hash_update_page(hdesc, __page, 0,
-				used_number * sizeof(*guard_start));
-			used_number = 0;
-		}
-
 		nob -= pga[i]->count;
 		pg_count--;
 		i++;
 	}
 	kunmap(__page);
 	if (rc)
-		goto out;
+		goto out_hash;
 
 	if (used_number != 0)
 		cfs_crypto_hash_update_page(hdesc, __page, 0,
 			used_number * sizeof(*guard_start));
 
-	bufsize = sizeof(cksum);
-	cfs_crypto_hash_final(hdesc, (unsigned char *)&cksum, &bufsize);
-
-	/* For sending we only compute the wrong checksum instead
-	 * of corrupting the data so it is still correct on a redo
-	 */
-	if (opc == OST_WRITE && OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_SEND))
-		cksum++;
+out_hash:
+	rc2 = cfs_crypto_hash_final(hdesc, (unsigned char *)&cksum, &bufsize);
+	if (!rc)
+		rc = rc2;
+	if (rc == 0) {
+		/* For sending we only compute the wrong checksum instead
+		 * of corrupting the data so it is still correct on a redo
+		 */
+		if (opc == OST_WRITE &&
+		    OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_SEND))
+			cksum++;
 
-	*check_sum = cksum;
+		*check_sum = cksum;
+	}
 out:
 	__free_page(__page);
 	return rc;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
