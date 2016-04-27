From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 27 Apr 2016 15:28:47 +0300
Subject: [lustre-devel] staging: add Lustre file system client support
Message-ID: <20160427122846.GA6441@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Lustre devs,

The patch d7e09d0397e8: "staging: add Lustre file system client
support" from May 2, 2013, leads to the following Parfait warning.
Parfait is an Oracle static analysis tool.  If there is a patch from
this could you give credit to Lidza Louina <lidza.louina@oracle.com>?

drivers/staging/lustre/lustre/ldlm/interval_tree.c
   399  void interval_erase(struct interval_node *node,
   400                      struct interval_node **root)
   401  {
   402          struct interval_node *child, *parent;
   403          int color;
   404  
   405          LASSERT(interval_is_intree(node));
   406          node->in_intree = 0;
   407          if (!node->in_left) {
   408                  child = node->in_right;
   409          } else if (!node->in_right) {
   410                  child = node->in_left;
   411          } else { /* Both left and right child are not NULL */
   412                  struct interval_node *old = node;
   413  
   414                  node = interval_next(node);
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^
It looks like interval_next() can return NULL.

   415                  child = node->in_right;
   416                  parent = node->in_parent;
   417                  color = node->in_color;
   418  

Here is the interval_next() function:

drivers/staging/lustre/lustre/ldlm/interval_tree.c
   111  static struct interval_node *interval_next(struct interval_node *node)
   112  {
   113          if (!node)
   114                  return NULL;
   115          if (node->in_right)
   116                  return interval_first(node->in_right);
   117          while (node->in_parent && node_is_right_child(node))
                       ^^^^^^^^^^^^^^^
We assume that ->in_parent can be NULL here.  Is that actually possible?

   118                  node = node->in_parent;
   119          return node->in_parent;
   120  }

regards,
dan carpenter
