From: James Simmons <jsimmons@infradead.org>
Date: Wed, 21 Oct 2015 21:52:49 -0400
Subject: [lustre-devel] [PATCH 11/11] staging: lustre: Use C99 initializers
	for struct netstrfns
In-Reply-To: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
References: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445478769-21203-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Update struct netstrfns to use C99 initializers.

Remove old LND types from the netstrfns table, as they are
long obsolete and shouldn't be needed even for interop anymore.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6210
Reviewed-on: http://review.whamcloud.com/15088
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
---
 drivers/staging/lustre/lnet/lnet/nidstrings.c |  188 +++++++------------------
 1 files changed, 51 insertions(+), 137 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index a5cd0ae..80f585a 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -893,12 +893,6 @@ libcfs_decnum_addr2str(__u32 addr, char *str, size_t size)
 	snprintf(str, size, "%u", addr);
 }
 
-static void
-libcfs_hexnum_addr2str(__u32 addr, char *str, size_t size)
-{
-	snprintf(str, size, "0x%x", addr);
-}
-
 static int
 libcfs_num_str2addr(const char *str, int nob, __u32 *addr)
 {
@@ -970,137 +964,57 @@ libcfs_num_match(__u32 addr, struct list_head *numaddr)
 	return cfs_expr_list_match(addr, el);
 }
 
-static struct netstrfns  libcfs_netstrfns[] = {
-	{/* .nf_type      */  LOLND,
-	 /* .nf_name      */  "lo",
-	 /* .nf_modname   */  "klolnd",
-	 /* .nf_addr2str  */  libcfs_decnum_addr2str,
-	 /* .nf_str2addr  */  libcfs_lo_str2addr,
-	 /* .nf_parse_addr*/  libcfs_num_parse,
-	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
-	 /* .nf_match_addr*/  libcfs_num_match,
-	 /* .nf_is_contiguous */  cfs_num_is_contiguous,
-	 /* .nf_min_max   */      cfs_num_min_max},
-	{/* .nf_type      */  SOCKLND,
-	 /* .nf_name      */  "tcp",
-	 /* .nf_modname   */  "ksocklnd",
-	 /* .nf_addr2str  */  libcfs_ip_addr2str,
-	 /* .nf_str2addr  */  libcfs_ip_str2addr,
-	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
-	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match,
-	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
-         /* .nf_min_max   */      cfs_ip_min_max},
-	{/* .nf_type      */  O2IBLND,
-	 /* .nf_name      */  "o2ib",
-	 /* .nf_modname   */  "ko2iblnd",
-	 /* .nf_addr2str  */  libcfs_ip_addr2str,
-	 /* .nf_str2addr  */  libcfs_ip_str2addr,
-	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
-	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match,
-	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
-         /* .nf_min_max   */      cfs_ip_min_max},
-	{/* .nf_type      */  CIBLND,
-	 /* .nf_name      */  "cib",
-	 /* .nf_modname   */  "kciblnd",
-	 /* .nf_addr2str  */  libcfs_ip_addr2str,
-	 /* .nf_str2addr  */  libcfs_ip_str2addr,
-	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
-	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match,
-	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
-         /* .nf_min_max   */      cfs_ip_min_max},
-	{/* .nf_type      */  OPENIBLND,
-	 /* .nf_name      */  "openib",
-	 /* .nf_modname   */  "kopeniblnd",
-	 /* .nf_addr2str  */  libcfs_ip_addr2str,
-	 /* .nf_str2addr  */  libcfs_ip_str2addr,
-	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
-	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match,
-	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
-         /* .nf_min_max   */      cfs_ip_min_max},
-	{/* .nf_type      */  IIBLND,
-	 /* .nf_name      */  "iib",
-	 /* .nf_modname   */  "kiiblnd",
-	 /* .nf_addr2str  */  libcfs_ip_addr2str,
-	 /* .nf_str2addr  */  libcfs_ip_str2addr,
-	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
-	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match,
-	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
-         /* .nf_min_max   */      cfs_ip_min_max},
-	{/* .nf_type      */  VIBLND,
-	 /* .nf_name      */  "vib",
-	 /* .nf_modname   */  "kviblnd",
-	 /* .nf_addr2str  */  libcfs_ip_addr2str,
-	 /* .nf_str2addr  */  libcfs_ip_str2addr,
-	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
-	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match,
-	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
-         /* .nf_min_max   */      cfs_ip_min_max},
-	{/* .nf_type      */  RALND,
-	 /* .nf_name      */  "ra",
-	 /* .nf_modname   */  "kralnd",
-	 /* .nf_addr2str  */  libcfs_ip_addr2str,
-	 /* .nf_str2addr  */  libcfs_ip_str2addr,
-	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
-	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match,
-	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
-         /* .nf_min_max   */      cfs_ip_min_max},
-	{/* .nf_type      */  QSWLND,
-	 /* .nf_name      */  "elan",
-	 /* .nf_modname   */  "kqswlnd",
-	 /* .nf_addr2str  */  libcfs_decnum_addr2str,
-	 /* .nf_str2addr  */  libcfs_num_str2addr,
-	 /* .nf_parse_addrlist*/  libcfs_num_parse,
-	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
-	 /* .nf_match_addr*/  libcfs_num_match,
-	 /* .nf_is_contiguous */  cfs_num_is_contiguous,
-	 /* .nf_min_max   */      cfs_num_min_max},
-	{/* .nf_type      */  GMLND,
-	 /* .nf_name      */  "gm",
-	 /* .nf_modname   */  "kgmlnd",
-	 /* .nf_addr2str  */  libcfs_hexnum_addr2str,
-	 /* .nf_str2addr  */  libcfs_num_str2addr,
-	 /* .nf_parse_addrlist*/  libcfs_num_parse,
-	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
-	 /* .nf_match_addr*/  libcfs_num_match,
-	 /* .nf_is_contiguous */  cfs_num_is_contiguous,
-	 /* .nf_min_max   */      cfs_num_min_max},
-	{/* .nf_type      */  MXLND,
-	 /* .nf_name      */  "mx",
-	 /* .nf_modname   */  "kmxlnd",
-	 /* .nf_addr2str  */  libcfs_ip_addr2str,
-	 /* .nf_str2addr  */  libcfs_ip_str2addr,
-	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
-	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match,
-	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
-         /* .nf_min_max   */      cfs_ip_min_max},
-	{/* .nf_type      */  PTLLND,
-	 /* .nf_name      */  "ptl",
-	 /* .nf_modname   */  "kptllnd",
-	 /* .nf_addr2str  */  libcfs_decnum_addr2str,
-	 /* .nf_str2addr  */  libcfs_num_str2addr,
-	 /* .nf_parse_addrlist*/  libcfs_num_parse,
-	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
-	 /* .nf_match_addr*/  libcfs_num_match,
-	 /* .nf_is_contiguous */  cfs_num_is_contiguous,
-	 /* .nf_min_max   */      cfs_num_min_max},
-	{/* .nf_type      */  GNILND,
-	 /* .nf_name      */  "gni",
-	 /* .nf_modname   */  "kgnilnd",
-	 /* .nf_addr2str  */  libcfs_decnum_addr2str,
-	 /* .nf_str2addr  */  libcfs_num_str2addr,
-	 /* .nf_parse_addrlist*/  libcfs_num_parse,
-	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
-	 /* .nf_match_addr*/  libcfs_num_match,
-	 /* .nf_is_contiguous */  cfs_num_is_contiguous,
-	 /* .nf_min_max   */      cfs_num_min_max},
+static struct netstrfns libcfs_netstrfns[] = {
+	{ .nf_type		= LOLND,
+	  .nf_name		= "lo",
+	  .nf_modname		= "klolnd",
+	  .nf_addr2str		= libcfs_decnum_addr2str,
+	  .nf_str2addr		= libcfs_lo_str2addr,
+	  .nf_parse_addrlist	= libcfs_num_parse,
+	  .nf_print_addrlist	= libcfs_num_addr_range_print,
+	  .nf_match_addr	= libcfs_num_match,
+	  .nf_is_contiguous	= cfs_num_is_contiguous,
+	  .nf_min_max		= cfs_num_min_max },
+	{ .nf_type		= SOCKLND,
+	  .nf_name		= "tcp",
+	  .nf_modname		= "ksocklnd",
+	  .nf_addr2str		= libcfs_ip_addr2str,
+	  .nf_str2addr		= libcfs_ip_str2addr,
+	  .nf_parse_addrlist	= cfs_ip_addr_parse,
+	  .nf_print_addrlist	= libcfs_ip_addr_range_print,
+	  .nf_match_addr	= cfs_ip_addr_match,
+	  .nf_is_contiguous	= cfs_ip_is_contiguous,
+	  .nf_min_max		= cfs_ip_min_max },
+	{ .nf_type		= O2IBLND,
+	  .nf_name		= "o2ib",
+	  .nf_modname		= "ko2iblnd",
+	  .nf_addr2str		= libcfs_ip_addr2str,
+	  .nf_str2addr		= libcfs_ip_str2addr,
+	  .nf_parse_addrlist	= cfs_ip_addr_parse,
+	  .nf_print_addrlist	= libcfs_ip_addr_range_print,
+	  .nf_match_addr	= cfs_ip_addr_match,
+	  .nf_is_contiguous	= cfs_ip_is_contiguous,
+	  .nf_min_max		= cfs_ip_min_max },
+	{ .nf_type		= GNILND,
+	  .nf_name		= "gni",
+	  .nf_modname		= "kgnilnd",
+	  .nf_addr2str		= libcfs_decnum_addr2str,
+	  .nf_str2addr		= libcfs_num_str2addr,
+	  .nf_parse_addrlist	= libcfs_num_parse,
+	  .nf_print_addrlist	= libcfs_num_addr_range_print,
+	  .nf_match_addr	= libcfs_num_match,
+	  .nf_is_contiguous	= cfs_num_is_contiguous,
+	  .nf_min_max		= cfs_num_min_max },
+	{ .nf_type		= GNIIPLND,
+	  .nf_name		= "gip",
+	  .nf_modname		= "kgnilnd",
+	  .nf_addr2str		= libcfs_ip_addr2str,
+	  .nf_str2addr		= libcfs_ip_str2addr,
+	  .nf_parse_addrlist	= cfs_ip_addr_parse,
+	  .nf_print_addrlist	= libcfs_ip_addr_range_print,
+	  .nf_match_addr	= cfs_ip_addr_match,
+	  .nf_is_contiguous	= cfs_ip_is_contiguous,
+	  .nf_min_max		= cfs_ip_min_max },
 };
 
 static const size_t libcfs_nnetstrfns = ARRAY_SIZE(libcfs_netstrfns);
-- 
1.7.1
