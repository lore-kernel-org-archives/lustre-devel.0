From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:26:57 -0400
Subject: [lustre-devel] [PATCH 01/20] lnet: fix kmalloc size in config.c
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

sizeof(net->net_cpts) should be sizeof(*net->net_cpts).

For consistency, also change a sizeof(ni->ni_cpts[0]) to
sizeof(*ni->ni_cpts).

and when allocating 'array' use sizeof(*array), not
sizeof(*net->net_cpts);

Fixes: 47db2bfba415 ("lnet: add list of cpts to lnet_net.")
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/lnet/lnet/config.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 3fc0298..9f36c82 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -171,7 +171,7 @@ struct lnet_text_buf {		/* tmp struct for parsing routes */
 	}
 
 	if (!net->net_cpts) {
-		net->net_cpts = kmalloc_array(ncpts, sizeof(net->net_cpts),
+		net->net_cpts = kmalloc_array(ncpts, sizeof(*net->net_cpts),
 					      GFP_KERNEL);
 		if (!net->net_cpts)
 			return -ENOMEM;
@@ -197,7 +197,7 @@ struct lnet_text_buf {		/* tmp struct for parsing routes */
 		u32 *array = NULL, *loc;
 		u32 total_entries = j + net->net_ncpts;
 
-		array = kmalloc_array(total_entries, sizeof(*net->net_cpts),
+		array = kmalloc_array(total_entries, sizeof(*array),
 				      GFP_KERNEL);
 		if (!array) {
 			rc = -ENOMEM;
@@ -545,7 +545,7 @@ struct lnet_ni *
 	} else {
 		size_t array_size = ncpts * sizeof(ni->ni_cpts[0]);
 
-		ni->ni_cpts = kmalloc_array(ncpts, sizeof(ni->ni_cpts[0]),
+		ni->ni_cpts = kmalloc_array(ncpts, sizeof(*ni->ni_cpts),
 					    GFP_KERNEL);
 		if (!ni->ni_cpts)
 			goto failed;
-- 
1.8.3.1
