Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 38AA9C0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:40:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLgw0wnyz228v;
	Thu, 30 Jan 2025 06:17:16 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLc85nFDz211D
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:14:00 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 3A16F899ADD;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 38480106BE16; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:12 -0500
Message-ID: <20250130141115.950749-23-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 22/25] lustre: obdclass: Free t10pi crypto
 state on error
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

From: Oleg Drokin <green@whamcloud.com>

Looks like when error happens we forgot to release crypto state that
not only leaks memory directly, but potentially can tie in-memory
pages too.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15615
Lustre-commit: 6a88222bd6a1c0f5b ("LU-15615 target: Free t10pi crypto state on error")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50539
Reviewed-by: Li Xi <lixi@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/integrity.c | 35 ++++++++++++++++++----------------
 1 file changed, 19 insertions(+), 16 deletions(-)

diff --git a/fs/lustre/obdclass/integrity.c b/fs/lustre/obdclass/integrity.c
index e6069cb30213..57f52ab829cd 100644
--- a/fs/lustre/obdclass/integrity.c
+++ b/fs/lustre/obdclass/integrity.c
@@ -45,37 +45,40 @@ __be16 obd_dif_ip_fn(void *data, unsigned int len)
 EXPORT_SYMBOL(obd_dif_ip_fn);
 
 int obd_page_dif_generate_buffer(const char *obd_name, struct page *page,
-				 u32 offset, u32 length,
+				 u32 start, u32 length,
 				 __be16 *guard_start, int guard_number,
 				 int *used_number, int sector_size,
 				 obd_dif_csum_fn *fn)
 {
-	unsigned int i = offset;
-	unsigned int end = offset + length;
+	unsigned int off = start;
+	unsigned int end = start + length;
 	char *data_buf;
 	__be16 *guard_buf = guard_start;
 	unsigned int data_size;
-	int used = 0;
+	int guard_used = 0;
+	int rc = 0;
 
-	data_buf = kmap(page) + offset;
-	while (i < end) {
-		if (used >= guard_number) {
-			CERROR("%s: unexpected used guard number of DIF %u/%u, data length %u, sector size %u: rc = %d\n",
-			       obd_name, used, guard_number, length,
-			       sector_size, -E2BIG);
-			return -E2BIG;
+	data_buf = kmap(page) + start;
+	while (off < end) {
+		if (guard_used >= guard_number) {
+			rc = -E2BIG;
+			CERROR("%s: used %u >= guard %u, data %u+%u, sector_size %u: rc = %d\n",
+			       obd_name, guard_used, guard_number, start,
+			       length, sector_size, rc);
+			goto out;
 		}
-		data_size = min(round_up(i + 1, sector_size), end) - i;
+		data_size = min(round_up(off + 1, sector_size), end) - off;
 		*guard_buf = fn(data_buf, data_size);
 		guard_buf++;
+		guard_used++;
 		data_buf += data_size;
-		i += data_size;
-		used++;
+		off += data_size;
 	}
+	*used_number = guard_used;
+out:
 	kunmap(page);
-	*used_number = used;
 
-	return 0;
+	return rc;
 }
 EXPORT_SYMBOL(obd_page_dif_generate_buffer);
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
