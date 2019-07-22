From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 14:16:47 +1000
Subject: [lustre-devel] [PATCH 02/22] ext4: use d_find_alias() in
 ext4_lookup
In-Reply-To: <1563758631-29550-3-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-3-git-send-email-jsimmons@infradead.org>
Message-ID: <87tvbeputs.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> From: James Simmons <uja.ornl@yahoo.com>
>
> Really old bug that might not even exist anymore?

If there is a bug, it is somewhere else.
ext4_lookup() should never be called on "." or "..".
Whatever calls ext4_lookup must filter those out if there are a
possibility.

NeilBrown


>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  fs/ext4/namei.c | 29 +++++++++++++++++++++++++++++
>  1 file changed, 29 insertions(+)
>
> diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
> index cd01c4a..a616f58 100644
> --- a/fs/ext4/namei.c
> +++ b/fs/ext4/namei.c
> @@ -1664,6 +1664,35 @@ static struct dentry *ext4_lookup(struct inode *dir, struct dentry *dentry, unsi
>  		}
>  	}
>  
> +	/* ".." shouldn't go into dcache to preserve dcache hierarchy
> +	 * otherwise we'll get parent being a child of actual child.
> +	 * see bug 10458 for details -bzzz
> +	 */
> +	if (inode && (dentry->d_name.name[0] == '.' &&
> +		      (dentry->d_name.len == 1 || (dentry->d_name.len == 2 &&
> +						   dentry->d_name.name[1] == '.')))) {
> +		struct dentry *goal = NULL;
> +
> +		/* first, look for an existing dentry - any one is good */
> +		goal = d_find_any_alias(inode);
> +		if (!goal) {
> +			spin_lock(&dentry->d_lock);
> +			/* there is no alias, we need to make current dentry:
> +			 *  a) inaccessible for __d_lookup()
> +			 *  b) inaccessible for iopen
> +			 */
> +			J_ASSERT(hlist_unhashed(&dentry->d_u.d_alias));
> +			dentry->d_flags |= DCACHE_NFSFS_RENAMED;
> +			/* this is d_instantiate() ... */
> +			hlist_add_head(&dentry->d_u.d_alias, &inode->i_dentry);
> +			dentry->d_inode = inode;
> +			spin_unlock(&dentry->d_lock);
> +		}
> +		if (goal)
> +			iput(inode);
> +		return goal;
> +	}
> +
>  #ifdef CONFIG_UNICODE
>  	if (!inode && IS_CASEFOLDED(dir)) {
>  		/* Eventually we want to call d_add_ci(dentry, NULL)
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/502da634/attachment-0001.sig>
