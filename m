From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Fri, 13 May 2016 16:18:57 +0000
Subject: [lustre-devel] staging: add Lustre file system client support
In-Reply-To: <20160427122846.GA6441@mwanda>
References: <20160427122846.GA6441@mwanda>
Message-ID: <2312D059-0594-4A81-90F8-E439C1A533B0@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Apr 27, 2016, at 8:28 AM, Dan Carpenter wrote:

> Hello Lustre devs,
> 
> The patch d7e09d0397e8: "staging: add Lustre file system client
> support" from May 2, 2013, leads to the following Parfait warning.
> Parfait is an Oracle static analysis tool.  If there is a patch from
> this could you give credit to Lidza Louina <lidza.louina@oracle.com>?
> 
> drivers/staging/lustre/lustre/ldlm/interval_tree.c
>   399  void interval_erase(struct interval_node *node,
>   400                      struct interval_node **root)
>   401  {
>   402          struct interval_node *child, *parent;
>   403          int color;
>   404  
>   405          LASSERT(interval_is_intree(node));
>   406          node->in_intree = 0;
>   407          if (!node->in_left) {
>   408                  child = node->in_right;
>   409          } else if (!node->in_right) {
>   410                  child = node->in_left;
>   411          } else { /* Both left and right child are not NULL */
>   412                  struct interval_node *old = node;
>   413  
>   414                  node = interval_next(node);
>                        ^^^^^^^^^^^^^^^^^^^^^^^^^^
> It looks like interval_next() can return NULL.

In fact it cannot.
When we are called here, node->in_right is not NULL.

> 
>   415                  child = node->in_right;
>   416                  parent = node->in_parent;
>   417                  color = node->in_color;
>   418  
> 
> Here is the interval_next() function:
> 
> drivers/staging/lustre/lustre/ldlm/interval_tree.c
>   111  static struct interval_node *interval_next(struct interval_node *node)
>   112  {
>   113          if (!node)
>   114                  return NULL;
>   115          if (node->in_right)
>   116                  return interval_first(node->in_right);

So we take this branch here. and interval_first does not return NULL unless node itself is NULL.


Thanks.

Bye,
    Oleg
