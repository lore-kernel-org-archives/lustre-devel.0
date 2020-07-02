From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:54 -0400
Subject: [lustre-devel] [PATCH 14/18] lnet: define new network driver ptl4lnd
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Gregoire Pichon <gregoire.pichon@bull.net>

Assign an ID to the new network driver ptl4lnd developed by Bull
that implements a LND based on Portals 4 API. It is intended to be
used with BXI, the Bull interconnect hardware.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8932
Lustre-commit: c54bf3faa29f5 ("LU-8932 lnet: define new network driver ptl4lnd")
Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
Reviewed-on: https://review.whamcloud.com/24768
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/nidstr.h | 1 +
 net/lnet/lnet/nidstrings.c       | 9 +++++++++
 2 files changed, 10 insertions(+)

diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index 9133641..34ba497 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -53,6 +53,7 @@ enum {
 	/*MXLND		= 12, removed v2_7_50_0-34-g8be9e41	*/
 	GNILND		= 13,
 	GNIIPLND	= 14,
+	PTL4LND		= 15,
 
 	NUM_LNDS
 };
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index eca5092..fb8d3e2 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -692,6 +692,15 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 	  .nf_print_addrlist	= libcfs_ip_addr_range_print,
 	  .nf_match_addr	= cfs_ip_addr_match
 	},
+	{ .nf_type		= PTL4LND,
+	  .nf_name		= "ptlf",
+	  .nf_modname		= "kptl4lnd",
+	  .nf_addr2str		= libcfs_decnum_addr2str,
+	  .nf_str2addr		= libcfs_num_str2addr,
+	  .nf_parse_addrlist	= libcfs_num_parse,
+	  .nf_print_addrlist	= libcfs_num_addr_range_print,
+	  .nf_match_addr	= libcfs_num_match
+	},
 };
 
 static const size_t libcfs_nnetstrfns = ARRAY_SIZE(libcfs_netstrfns);
-- 
1.8.3.1
