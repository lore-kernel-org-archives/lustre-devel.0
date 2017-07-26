From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:26 -0400
Subject: [lustre-devel] [PATCH 10/20] staging: lustre: ldlm: restore
	interval_iterate_reverse function
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Earlier the function interval_iterate_reverse function was
removed since it wasn't used by anyone. Now it is being
restored since it will be used by a future patch.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/interval_tree.h  |  4 +++
 drivers/staging/lustre/lustre/ldlm/interval_tree.c | 40 ++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/drivers/staging/lustre/lustre/include/interval_tree.h b/drivers/staging/lustre/lustre/include/interval_tree.h
index 0d4f92e..a4d7280 100644
--- a/drivers/staging/lustre/lustre/include/interval_tree.h
+++ b/drivers/staging/lustre/lustre/include/interval_tree.h
@@ -111,4 +111,8 @@ enum interval_iter interval_search(struct interval_node *root,
 				   struct interval_node_extent *ex,
 				   interval_callback_t func, void *data);
 
+enum interval_iter interval_iterate_reverse(struct interval_node *root,
+					    interval_callback_t func,
+					    void *data);
+
 #endif
diff --git a/drivers/staging/lustre/lustre/ldlm/interval_tree.c b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
index e106902..5bebd9a 100644
--- a/drivers/staging/lustre/lustre/ldlm/interval_tree.c
+++ b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
@@ -110,6 +110,15 @@ static struct interval_node *interval_first(struct interval_node *node)
 	return node;
 }
 
+static struct interval_node *interval_last(struct interval_node *node)
+{
+	if (!node)
+		return NULL;
+	while (node->in_right)
+		node = node->in_right;
+	return node;
+}
+
 static struct interval_node *interval_next(struct interval_node *node)
 {
 	if (!node)
@@ -121,6 +130,37 @@ static struct interval_node *interval_next(struct interval_node *node)
 	return node->in_parent;
 }
 
+static struct interval_node *interval_prev(struct interval_node *node)
+{
+	if (!node)
+		return NULL;
+
+	if (node->in_left)
+		return interval_last(node->in_left);
+
+	while (node->in_parent && node_is_left_child(node))
+		node = node->in_parent;
+
+	return node->in_parent;
+}
+
+enum interval_iter interval_iterate_reverse(struct interval_node *root,
+					    interval_callback_t func,
+					    void *data)
+{
+	enum interval_iter rc = INTERVAL_ITER_CONT;
+	struct interval_node *node;
+
+	for (node = interval_last(root); node; node = interval_prev(node)) {
+		rc = func(node, data);
+		if (rc == INTERVAL_ITER_STOP)
+			break;
+	}
+
+	return rc;
+}
+EXPORT_SYMBOL(interval_iterate_reverse);
+
 static void __rotate_change_maxhigh(struct interval_node *node,
 				    struct interval_node *rotate)
 {
-- 
1.8.3.1
