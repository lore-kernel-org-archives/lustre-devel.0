Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 821C3C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:21:06 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15N71C8Xz2274;
	Mon, 23 Jan 2023 15:07:19 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15My47qzz226g
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:07:10 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 84D88A05;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8162358987; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:40 -0500
Message-Id: <1674514855-15399-28-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 27/42] lustre: obdclass: fix T10PI prototypes
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
Cc: Li Dongyang <dongyangli@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Li Dongyang <dongyangli@ddn.com>

Update the custom generate and verify functions, to sync
with upstream versions.
 - Use __be16 instead of __u16 for guard tags.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16413
Lustre-commit: 4f0273b3bc7d2159d ("LU-16413 osd-ldiskfs: fix T10PI for CentOS 8.x")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49441
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_cksum.h  |  8 ++++----
 fs/lustre/obdclass/integrity.c | 12 ++++++------
 fs/lustre/osc/osc_request.c    |  4 ++--
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/include/obd_cksum.h b/fs/lustre/include/obd_cksum.h
index 1189bc2c73e9..36443fd5a156 100644
--- a/fs/lustre/include/obd_cksum.h
+++ b/fs/lustre/include/obd_cksum.h
@@ -129,13 +129,13 @@ enum cksum_types obd_cksum_type_select(const char *obd_name,
 #define DECLARE_CKSUM_NAME const char *const cksum_name[] = {"crc32", "adler", \
 	"crc32c", "reserved", "t10ip512", "t10ip4K", "t10crc512", "t10crc4K"}
 
-typedef u16 (obd_dif_csum_fn) (void *, unsigned int);
+typedef __be16 (obd_dif_csum_fn) (void *, unsigned int);
 
-u16 obd_dif_crc_fn(void *data, unsigned int len);
-u16 obd_dif_ip_fn(void *data, unsigned int len);
+__be16 obd_dif_crc_fn(void *data, unsigned int len);
+__be16 obd_dif_ip_fn(void *data, unsigned int len);
 int obd_page_dif_generate_buffer(const char *obd_name, struct page *page,
 				 u32 offset, u32 length,
-				 u16 *guard_start, int guard_number,
+				 __be16 *guard_start, int guard_number,
 				 int *used_number, int sector_size,
 				 obd_dif_csum_fn *fn);
 /*
diff --git a/fs/lustre/obdclass/integrity.c b/fs/lustre/obdclass/integrity.c
index 7a95a11f112f..e6069cb30213 100644
--- a/fs/lustre/obdclass/integrity.c
+++ b/fs/lustre/obdclass/integrity.c
@@ -32,13 +32,13 @@
 #include <obd_class.h>
 #include <obd_cksum.h>
 
-u16 obd_dif_crc_fn(void *data, unsigned int len)
+__be16 obd_dif_crc_fn(void *data, unsigned int len)
 {
 	return cpu_to_be16(crc_t10dif(data, len));
 }
 EXPORT_SYMBOL(obd_dif_crc_fn);
 
-u16 obd_dif_ip_fn(void *data, unsigned int len)
+__be16 obd_dif_ip_fn(void *data, unsigned int len)
 {
 	return ip_compute_csum(data, len);
 }
@@ -46,14 +46,14 @@ EXPORT_SYMBOL(obd_dif_ip_fn);
 
 int obd_page_dif_generate_buffer(const char *obd_name, struct page *page,
 				 u32 offset, u32 length,
-				 u16 *guard_start, int guard_number,
+				 __be16 *guard_start, int guard_number,
 				 int *used_number, int sector_size,
 				 obd_dif_csum_fn *fn)
 {
 	unsigned int i = offset;
 	unsigned int end = offset + length;
 	char *data_buf;
-	u16 *guard_buf = guard_start;
+	__be16 *guard_buf = guard_start;
 	unsigned int data_size;
 	int used = 0;
 
@@ -90,7 +90,7 @@ static int __obd_t10_performance_test(const char *obd_name,
 	unsigned int bufsize;
 	unsigned char *buffer;
 	struct page *__page;
-	u16 *guard_start;
+	__be16 *guard_start;
 	int guard_number;
 	int used_number = 0;
 	int sector_size = 0;
@@ -117,7 +117,7 @@ static int __obd_t10_performance_test(const char *obd_name,
 	}
 
 	buffer = kmap(__page);
-	guard_start = (u16 *)buffer;
+	guard_start = (__be16 *)buffer;
 	guard_number = PAGE_SIZE / sizeof(*guard_start);
 	for (i = 0; i < repeat_number; i++) {
 		/*
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 5a3f418615ca..fb0facc8ddd1 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1196,7 +1196,7 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 	unsigned char cfs_alg = cksum_obd2cfs(OBD_CKSUM_T10_TOP);
 	struct page *__page;
 	unsigned char *buffer;
-	u16 *guard_start;
+	__be16 *guard_start;
 	unsigned int bufsize;
 	int guard_number;
 	int used_number = 0;
@@ -1220,7 +1220,7 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 	}
 
 	buffer = kmap(__page);
-	guard_start = (u16 *)buffer;
+	guard_start = (__be16 *)buffer;
 	guard_number = PAGE_SIZE / sizeof(*guard_start);
 	CDEBUG(D_PAGE | (resend ? D_HA : 0),
 	       "GRD tags per page=%u, resend=%u, bytes=%u, pages=%zu\n",
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
