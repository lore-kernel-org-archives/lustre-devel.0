Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 15A8EC19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:40:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyryd4tS7z23Hq;
	Wed,  3 Aug 2022 18:40:25 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwl1zQvz23Hx
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 05A84100B055;
 Wed,  3 Aug 2022 21:38:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 02DD180795; Wed,  3 Aug 2022 21:38:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:14 -0400
Message-Id: <1659577097-19253-30-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 29/32] lustre: ec: code to add support for M
 to N parity
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
Cc: Adam Disney <disneyaw@ornl.gov>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

This code adds basic functionality for calculating N parities
for M data units. This allows much more than just working with
raid6 calculations. The code is derived from the Intel isa-l
userland library. Keep the code in an separate module for easy
merger upstream at a latter time.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12189
Lustre-commit: 047347170b8aece43 ("LU-12189 ec: code to add support for M to N parity")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: Adam Disney <disneyaw@ornl.gov>
Reviewed-on: https://review.whamcloud.com/47628
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/Makefile               |   2 +-
 fs/lustre/ec/Makefile            |   4 +
 fs/lustre/ec/ec_base.c           | 352 +++++++++++++++++++++++++++++++++++++++
 fs/lustre/include/erasure_code.h | 142 ++++++++++++++++
 4 files changed, 499 insertions(+), 1 deletion(-)
 create mode 100644 fs/lustre/ec/Makefile
 create mode 100644 fs/lustre/ec/ec_base.c
 create mode 100644 fs/lustre/include/erasure_code.h

diff --git a/fs/lustre/Makefile b/fs/lustre/Makefile
index 4a02463..4af6ff6 100644
--- a/fs/lustre/Makefile
+++ b/fs/lustre/Makefile
@@ -1,3 +1,3 @@
 
-obj-$(CONFIG_LUSTRE_FS) += obdclass/ ptlrpc/ fld/ osc/ mgc/ \
+obj-$(CONFIG_LUSTRE_FS) += obdclass/ ptlrpc/ fld/ osc/ mgc/ ec/ \
 			   fid/ lov/ mdc/ lmv/ llite/ obdecho/
diff --git a/fs/lustre/ec/Makefile b/fs/lustre/ec/Makefile
new file mode 100644
index 0000000..aba8ea3
--- /dev/null
+++ b/fs/lustre/ec/Makefile
@@ -0,0 +1,4 @@
+ccflags-y += -I$(srctree)/$(src)/../include
+
+obj-$(CONFIG_LUSTRE_FS) += ec.o
+ec-y := ec_base.o
diff --git a/fs/lustre/ec/ec_base.c b/fs/lustre/ec/ec_base.c
new file mode 100644
index 0000000..e520466
--- /dev/null
+++ b/fs/lustre/ec/ec_base.c
@@ -0,0 +1,352 @@
+// SPDX-License-Identifier: BSD-2-Clause
+/**********************************************************************
+ * Copyright(c) 2011-2015 Intel Corporation All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *    Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *    Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *    Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/limits.h>
+#include <linux/module.h>
+#include <linux/string.h>	/* for memset */
+
+#include "erasure_code.h"
+
+/* Global GF(256) tables */
+static const unsigned char gff_base[] = {
+	0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1d, 0x3a,
+	0x74, 0xe8, 0xcd, 0x87, 0x13, 0x26, 0x4c, 0x98, 0x2d, 0x5a,
+	0xb4, 0x75, 0xea, 0xc9, 0x8f, 0x03, 0x06, 0x0c, 0x18, 0x30,
+	0x60, 0xc0, 0x9d, 0x27, 0x4e, 0x9c, 0x25, 0x4a, 0x94, 0x35,
+	0x6a, 0xd4, 0xb5, 0x77, 0xee, 0xc1, 0x9f, 0x23, 0x46, 0x8c,
+	0x05, 0x0a, 0x14, 0x28, 0x50, 0xa0, 0x5d, 0xba, 0x69, 0xd2,
+	0xb9, 0x6f, 0xde, 0xa1, 0x5f, 0xbe, 0x61, 0xc2, 0x99, 0x2f,
+	0x5e, 0xbc, 0x65, 0xca, 0x89, 0x0f, 0x1e, 0x3c, 0x78, 0xf0,
+	0xfd, 0xe7, 0xd3, 0xbb, 0x6b, 0xd6, 0xb1, 0x7f, 0xfe, 0xe1,
+	0xdf, 0xa3, 0x5b, 0xb6, 0x71, 0xe2, 0xd9, 0xaf, 0x43, 0x86,
+	0x11, 0x22, 0x44, 0x88, 0x0d, 0x1a, 0x34, 0x68, 0xd0, 0xbd,
+	0x67, 0xce, 0x81, 0x1f, 0x3e, 0x7c, 0xf8, 0xed, 0xc7, 0x93,
+	0x3b, 0x76, 0xec, 0xc5, 0x97, 0x33, 0x66, 0xcc, 0x85, 0x17,
+	0x2e, 0x5c, 0xb8, 0x6d, 0xda, 0xa9, 0x4f, 0x9e, 0x21, 0x42,
+	0x84, 0x15, 0x2a, 0x54, 0xa8, 0x4d, 0x9a, 0x29, 0x52, 0xa4,
+	0x55, 0xaa, 0x49, 0x92, 0x39, 0x72, 0xe4, 0xd5, 0xb7, 0x73,
+	0xe6, 0xd1, 0xbf, 0x63, 0xc6, 0x91, 0x3f, 0x7e, 0xfc, 0xe5,
+	0xd7, 0xb3, 0x7b, 0xf6, 0xf1, 0xff, 0xe3, 0xdb, 0xab, 0x4b,
+	0x96, 0x31, 0x62, 0xc4, 0x95, 0x37, 0x6e, 0xdc, 0xa5, 0x57,
+	0xae, 0x41, 0x82, 0x19, 0x32, 0x64, 0xc8, 0x8d, 0x07, 0x0e,
+	0x1c, 0x38, 0x70, 0xe0, 0xdd, 0xa7, 0x53, 0xa6, 0x51, 0xa2,
+	0x59, 0xb2, 0x79, 0xf2, 0xf9, 0xef, 0xc3, 0x9b, 0x2b, 0x56,
+	0xac, 0x45, 0x8a, 0x09, 0x12, 0x24, 0x48, 0x90, 0x3d, 0x7a,
+	0xf4, 0xf5, 0xf7, 0xf3, 0xfb, 0xeb, 0xcb, 0x8b, 0x0b, 0x16,
+	0x2c, 0x58, 0xb0, 0x7d, 0xfa, 0xe9, 0xcf, 0x83, 0x1b, 0x36,
+	0x6c, 0xd8, 0xad, 0x47, 0x8e, 0x01
+};
+
+static const unsigned char gflog_base[] = {
+	0x00, 0xff, 0x01, 0x19, 0x02, 0x32, 0x1a, 0xc6, 0x03, 0xdf,
+	0x33, 0xee, 0x1b, 0x68, 0xc7, 0x4b, 0x04, 0x64, 0xe0, 0x0e,
+	0x34, 0x8d, 0xef, 0x81, 0x1c, 0xc1, 0x69, 0xf8, 0xc8, 0x08,
+	0x4c, 0x71, 0x05, 0x8a, 0x65, 0x2f, 0xe1, 0x24, 0x0f, 0x21,
+	0x35, 0x93, 0x8e, 0xda, 0xf0, 0x12, 0x82, 0x45, 0x1d, 0xb5,
+	0xc2, 0x7d, 0x6a, 0x27, 0xf9, 0xb9, 0xc9, 0x9a, 0x09, 0x78,
+	0x4d, 0xe4, 0x72, 0xa6, 0x06, 0xbf, 0x8b, 0x62, 0x66, 0xdd,
+	0x30, 0xfd, 0xe2, 0x98, 0x25, 0xb3, 0x10, 0x91, 0x22, 0x88,
+	0x36, 0xd0, 0x94, 0xce, 0x8f, 0x96, 0xdb, 0xbd, 0xf1, 0xd2,
+	0x13, 0x5c, 0x83, 0x38, 0x46, 0x40, 0x1e, 0x42, 0xb6, 0xa3,
+	0xc3, 0x48, 0x7e, 0x6e, 0x6b, 0x3a, 0x28, 0x54, 0xfa, 0x85,
+	0xba, 0x3d, 0xca, 0x5e, 0x9b, 0x9f, 0x0a, 0x15, 0x79, 0x2b,
+	0x4e, 0xd4, 0xe5, 0xac, 0x73, 0xf3, 0xa7, 0x57, 0x07, 0x70,
+	0xc0, 0xf7, 0x8c, 0x80, 0x63, 0x0d, 0x67, 0x4a, 0xde, 0xed,
+	0x31, 0xc5, 0xfe, 0x18, 0xe3, 0xa5, 0x99, 0x77, 0x26, 0xb8,
+	0xb4, 0x7c, 0x11, 0x44, 0x92, 0xd9, 0x23, 0x20, 0x89, 0x2e,
+	0x37, 0x3f, 0xd1, 0x5b, 0x95, 0xbc, 0xcf, 0xcd, 0x90, 0x87,
+	0x97, 0xb2, 0xdc, 0xfc, 0xbe, 0x61, 0xf2, 0x56, 0xd3, 0xab,
+	0x14, 0x2a, 0x5d, 0x9e, 0x84, 0x3c, 0x39, 0x53, 0x47, 0x6d,
+	0x41, 0xa2, 0x1f, 0x2d, 0x43, 0xd8, 0xb7, 0x7b, 0xa4, 0x76,
+	0xc4, 0x17, 0x49, 0xec, 0x7f, 0x0c, 0x6f, 0xf6, 0x6c, 0xa1,
+	0x3b, 0x52, 0x29, 0x9d, 0x55, 0xaa, 0xfb, 0x60, 0x86, 0xb1,
+	0xbb, 0xcc, 0x3e, 0x5a, 0xcb, 0x59, 0x5f, 0xb0, 0x9c, 0xa9,
+	0xa0, 0x51, 0x0b, 0xf5, 0x16, 0xeb, 0x7a, 0x75, 0x2c, 0xd7,
+	0x4f, 0xae, 0xd5, 0xe9, 0xe6, 0xe7, 0xad, 0xe8, 0x74, 0xd6,
+	0xf4, 0xea, 0xa8, 0x50, 0x58, 0xaf
+};
+
+void ec_init_tables(int k, int rows, unsigned char *a, unsigned char *g_tbls)
+{
+	int i, j;
+
+	for (i = 0; i < rows; i++) {
+		for (j = 0; j < k; j++) {
+			gf_vect_mul_init(*a++, g_tbls);
+			g_tbls += 32;
+		}
+	}
+}
+EXPORT_SYMBOL(ec_init_tables);
+
+unsigned char gf_mul(unsigned char a, unsigned char b)
+{
+	int i;
+
+	if ((a == 0) || (b == 0))
+		return 0;
+
+	i = gflog_base[a] + gflog_base[b];
+	return gff_base[i > 254 ? i - 255 : i];
+}
+
+unsigned char gf_inv(unsigned char a)
+{
+	if (a == 0)
+		return 0;
+
+	return gff_base[255 - gflog_base[a]];
+}
+
+void gf_gen_cauchy1_matrix(unsigned char *a, int m, int k)
+{
+	int i, j;
+	unsigned char *p;
+
+	/* Identity matrix in high position */
+	memset(a, 0, k * m);
+	for (i = 0; i < k; i++)
+		a[k * i + i] = 1;
+
+	/* For the rest choose 1/(i + j) | i != j */
+	p = &a[k * k];
+	for (i = k; i < m; i++)
+		for (j = 0; j < k; j++)
+			*p++ = gf_inv(i ^ j);
+
+}
+EXPORT_SYMBOL(gf_gen_cauchy1_matrix);
+
+int gf_invert_matrix(unsigned char *in_mat, unsigned char *out_mat, const int n)
+{
+	int i, j, k;
+	unsigned char temp;
+
+	/* Set out_mat[] to the identity matrix */
+	for (i = 0; i < n * n; i++)	/* memset(out_mat, 0, n*n) */
+		out_mat[i] = 0;
+
+	for (i = 0; i < n; i++)
+		out_mat[i * n + i] = 1;
+
+	/* Inverse */
+	for (i = 0; i < n; i++) {
+		/* Check for 0 in pivot element */
+		if (in_mat[i * n + i] == 0) {
+			/* Find a row with non-zero in current column and swap */
+			for (j = i + 1; j < n; j++)
+				if (in_mat[j * n + i])
+					break;
+
+			if (j == n)	/* Couldn't find means it's singular */
+				return -1;
+
+			for (k = 0; k < n; k++) {	/* Swap rows i,j */
+				temp = in_mat[i * n + k];
+				in_mat[i * n + k] = in_mat[j * n + k];
+				in_mat[j * n + k] = temp;
+
+				temp = out_mat[i * n + k];
+				out_mat[i * n + k] = out_mat[j * n + k];
+				out_mat[j * n + k] = temp;
+			}
+		}
+
+		temp = gf_inv(in_mat[i * n + i]);	/* 1/pivot */
+		for (j = 0; j < n; j++) {	/* Scale row i by 1/pivot */
+			in_mat[i * n + j] = gf_mul(in_mat[i * n + j], temp);
+			out_mat[i * n + j] = gf_mul(out_mat[i * n + j], temp);
+		}
+
+		for (j = 0; j < n; j++) {
+			if (j == i)
+				continue;
+
+			temp = in_mat[j * n + i];
+			for (k = 0; k < n; k++) {
+				out_mat[j * n + k] ^= gf_mul(temp, out_mat[i * n + k]);
+				in_mat[j * n + k] ^= gf_mul(temp, in_mat[i * n + k]);
+			}
+		}
+	}
+	return 0;
+}
+EXPORT_SYMBOL(gf_invert_matrix);
+
+/* Calculates const table gftbl in GF(2^8) from single input A
+ * gftbl(A) = {A{00}, A{01}, A{02}, ... , A{0f} }, {A{00}, A{10}, A{20}, ... ,
+ * A{f0} }
+ */
+void gf_vect_mul_init(unsigned char c, unsigned char *tbl)
+{
+	unsigned char c2 = (c << 1) ^ ((c & 0x80) ? 0x1d : 0);	/* Mult by
+								 * GF{2}
+								 */
+	unsigned char c4 = (c2 << 1) ^ ((c2 & 0x80) ? 0x1d : 0); /* Mult by
+								  * GF{2}
+								  */
+	unsigned char c8 = (c4 << 1) ^ ((c4 & 0x80) ? 0x1d : 0); /* Mult by
+								  * GF{2}
+								  */
+#if BITS_PER_LONG == 64
+	unsigned long long v1, v2, v4, v8, *t;
+	unsigned long long v10, v20, v40, v80;
+	unsigned char c17, c18, c20, c24;
+
+	t = (unsigned long long *)tbl;
+
+	v1 = c * 0x0100010001000100ull;
+	v2 = c2 * 0x0101000001010000ull;
+	v4 = c4 * 0x0101010100000000ull;
+	v8 = c8 * 0x0101010101010101ull;
+
+	v4 = v1 ^ v2 ^ v4;
+	t[0] = v4;
+	t[1] = v8 ^ v4;
+
+	c17 = (c8 << 1) ^ ((c8 & 0x80) ? 0x1d : 0);	//Mult by GF{2}
+	c18 = (c17 << 1) ^ ((c17 & 0x80) ? 0x1d : 0);	//Mult by GF{2}
+	c20 = (c18 << 1) ^ ((c18 & 0x80) ? 0x1d : 0);	//Mult by GF{2}
+	c24 = (c20 << 1) ^ ((c20 & 0x80) ? 0x1d : 0);	//Mult by GF{2}
+
+	v10 = c17 * 0x0100010001000100ull;
+	v20 = c18 * 0x0101000001010000ull;
+	v40 = c20 * 0x0101010100000000ull;
+	v80 = c24 * 0x0101010101010101ull;
+
+	v40 = v10 ^ v20 ^ v40;
+	t[2] = v40;
+	t[3] = v80 ^ v40;
+
+#else /* 32-bit or other */
+	unsigned char c3, c5, c6, c7, c9, c10, c11, c12, c13, c14, c15;
+	unsigned char c17, c18, c19, c20, c21, c22, c23, c24, c25, c26;
+	unsigned char c27, c28, c29, c30, c31;
+
+	c3 = c2 ^ c;
+	c5 = c4 ^ c;
+	c6 = c4 ^ c2;
+	c7 = c4 ^ c3;
+
+	c9 = c8 ^ c;
+	c10 = c8 ^ c2;
+	c11 = c8 ^ c3;
+	c12 = c8 ^ c4;
+	c13 = c8 ^ c5;
+	c14 = c8 ^ c6;
+	c15 = c8 ^ c7;
+
+	tbl[0] = 0;
+	tbl[1] = c;
+	tbl[2] = c2;
+	tbl[3] = c3;
+	tbl[4] = c4;
+	tbl[5] = c5;
+	tbl[6] = c6;
+	tbl[7] = c7;
+	tbl[8] = c8;
+	tbl[9] = c9;
+	tbl[10] = c10;
+	tbl[11] = c11;
+	tbl[12] = c12;
+	tbl[13] = c13;
+	tbl[14] = c14;
+	tbl[15] = c15;
+
+	c17 = (c8 << 1) ^ ((c8 & 0x80) ? 0x1d : 0);	/* Mult by GF{2} */
+	c18 = (c17 << 1) ^ ((c17 & 0x80) ? 0x1d : 0);	/* Mult by GF{2} */
+	c19 = c18 ^ c17;
+	c20 = (c18 << 1) ^ ((c18 & 0x80) ? 0x1d : 0);	/* Mult by GF{2} */
+	c21 = c20 ^ c17;
+	c22 = c20 ^ c18;
+	c23 = c20 ^ c19;
+	c24 = (c20 << 1) ^ ((c20 & 0x80) ? 0x1d : 0);	/* Mult by GF{2} */
+	c25 = c24 ^ c17;
+	c26 = c24 ^ c18;
+	c27 = c24 ^ c19;
+	c28 = c24 ^ c20;
+	c29 = c24 ^ c21;
+	c30 = c24 ^ c22;
+	c31 = c24 ^ c23;
+
+	tbl[16] = 0;
+	tbl[17] = c17;
+	tbl[18] = c18;
+	tbl[19] = c19;
+	tbl[20] = c20;
+	tbl[21] = c21;
+	tbl[22] = c22;
+	tbl[23] = c23;
+	tbl[24] = c24;
+	tbl[25] = c25;
+	tbl[26] = c26;
+	tbl[27] = c27;
+	tbl[28] = c28;
+	tbl[29] = c29;
+	tbl[30] = c30;
+	tbl[31] = c31;
+
+#endif /* BITS_PER_LONG == 64 */
+}
+
+void ec_encode_data(int len, int srcs, int dests, unsigned char *v,
+		    unsigned char **src, unsigned char **dest)
+{
+	int i, j, l;
+	unsigned char s;
+
+	for (l = 0; l < dests; l++) {
+		for (i = 0; i < len; i++) {
+			s = 0;
+			for (j = 0; j < srcs; j++)
+				s ^= gf_mul(src[j][i], v[j * 32 + l * srcs * 32 + 1]);
+
+			dest[l][i] = s;
+		}
+	}
+}
+EXPORT_SYMBOL(ec_encode_data);
+
+static int __init ec_init(void)
+{
+	return 0;
+}
+
+static void __exit ec_exit(void)
+{
+}
+
+MODULE_AUTHOR("Intel Corporation");
+MODULE_DESCRIPTION("M to N erasure code handling");
+MODULE_VERSION("1.0.0");
+MODULE_LICENSE("Dual BSD/GPL");
+
+module_init(ec_init);
+module_exit(ec_exit);
diff --git a/fs/lustre/include/erasure_code.h b/fs/lustre/include/erasure_code.h
new file mode 100644
index 0000000..9e62c2b
--- /dev/null
+++ b/fs/lustre/include/erasure_code.h
@@ -0,0 +1,142 @@
+// SPDX-License-Identifier: BSD-2-Clause
+/**********************************************************************
+ * Copyright(c) 2011-2015 Intel Corporation All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *    Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _ERASURE_CODE_H_
+#define _ERASURE_CODE_H_
+
+/**
+ *  @file erasure_code.h
+ *  @brief Interface to functions supporting erasure code encode and decode.
+ *
+ *  This file defines the interface to optimized functions used in erasure
+ *  codes.  Encode and decode of erasures in GF(2^8) are made by calculating the
+ *  dot product of the symbols (bytes in GF(2^8)) across a set of buffers and a
+ *  set of coefficients.  Values for the coefficients are determined by the type
+ *  of erasure code.  Using a general dot product means that any sequence of
+ *  coefficients may be used including erasure codes based on random
+ *  coefficients.
+ *  Multiple versions of dot product are supplied to calculate 1-6 output
+ *  vectors in one pass.
+ *  Base GF multiply and divide functions can be sped up by defining
+ *  GF_LARGE_TABLES at the expense of memory size.
+ *
+ */
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+/**
+ * @brief Initialize 32-byte constant array for GF(2^8) vector multiply
+ *
+ * Calculates array {C{00}, C{01}, C{02}, ... , C{0f} }, {C{00}, C{10},
+ * C{20}, ... , C{f0} } as required by other fast vector multiply
+ * functions.
+ * @param c     Constant input.
+ * @param gftbl Table output.
+ */
+void gf_vect_mul_init(unsigned char c, unsigned char *gftbl);
+
+/**
+ * @brief Initialize tables for fast Erasure Code encode and decode.
+ *
+ * Generates the expanded tables needed for fast encode or decode for erasure
+ * codes on blocks of data.  32bytes is generated for each input coefficient.
+ *
+ * @param k      The number of vector sources or rows in the generator matrix
+ *               for coding.
+ * @param rows   The number of output vectors to concurrently encode/decode.
+ * @param a      Pointer to sets of arrays of input coefficients used to encode
+ *               or decode data.
+ * @param gftbls Pointer to start of space for concatenated output tables
+ *               generated from input coefficients.  Must be of size 32*k*rows.
+ * @returns none
+ */
+void ec_init_tables(int k, int rows, unsigned char *a, unsigned char *gftbls);
+
+/**
+ * @brief Generate or decode erasure codes on blocks of data, runs appropriate
+ * version.
+ *
+ * Given a list of source data blocks, generate one or multiple blocks of
+ * encoded data as specified by a matrix of GF(2^8) coefficients. When given a
+ * suitable set of coefficients, this function will perform the fast generation
+ * or decoding of Reed-Solomon type erasure codes.
+ *
+ * This function determines what instruction sets are enabled and
+ * selects the appropriate version at runtime.
+ *
+ * @param len    Length of each block of data (vector) of source or dest data.
+ * @param k      The number of vector sources or rows in the generator matrix
+ *		 for coding.
+ * @param rows   The number of output vectors to concurrently encode/decode.
+ * @param gftbls Pointer to array of input tables generated from coding
+ *		  coefficients in ec_init_tables(). Must be of size 32*k*rows
+ * @param data   Array of pointers to source input buffers.
+ * @param coding Array of pointers to coded output buffers.
+ * @returns none
+ */
+void ec_encode_data(int len, int k, int rows, unsigned char *gftbls,
+		    unsigned char **data, unsigned char **coding);
+
+/**
+ * @brief Generate a Cauchy matrix of coefficients to be used for encoding.
+ *
+ * Cauchy matrix example of encoding coefficients where high portion of matrix
+ * is identity matrix I and lower portion is constructed as 1/(i + j) | i != j,
+ * i:{0,k-1} j:{k,m-1}.  Any sub-matrix of a Cauchy matrix should be invertable.
+ *
+ * @param a  [m x k] array to hold coefficients
+ * @param m  number of rows in matrix corresponding to srcs + parity.
+ * @param k  number of columns in matrix corresponding to srcs.
+ * @returns  none
+ */
+void gf_gen_cauchy1_matrix(unsigned char *a, int m, int k);
+
+/**
+ * @brief Invert a matrix in GF(2^8)
+ *
+ * Attempts to construct an n x n inverse of the input matrix. Returns non-zero
+ * if singular. Will always destroy input matrix in process.
+ *
+ * @param in  input matrix, destroyed by invert process
+ * @param out output matrix such that [in] x [out] = [I] - identity matrix
+ * @param n   size of matrix [nxn]
+ * @returns 0 successful, other fail on singular input matrix
+ */
+int gf_invert_matrix(unsigned char *in, unsigned char *out, const int n);
+
+/*************************************************************/
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* _ERASURE_CODE_H_ */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
