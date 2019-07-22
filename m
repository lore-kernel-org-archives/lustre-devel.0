From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 15:16:50 +1000
Subject: [lustre-devel] [PATCH 14/22] ext4: remove inode_lock handling
In-Reply-To: <1563758631-29550-15-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-15-git-send-email-jsimmons@infradead.org>
Message-ID: <871ryips1p.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> There will cause a deadlock if invoke ext4_truncate with i_mutex locked
> in lustre. Since lustre has own lock to provide protect so we don't
> need this check at all.

I guess you mean that if you took i_mutex in lustre, that would cause a
deadlock?

More evidence needed, and I strongly suspect that this is a bad idea.

NeilBrown


>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  fs/ext4/inode.c | 2 --
>  fs/ext4/namei.c | 4 ----
>  2 files changed, 6 deletions(-)
>
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 5561351..9296611 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -4474,8 +4474,6 @@ int ext4_truncate(struct inode *inode)
>  	 * or it's a completely new inode. In those cases we might not
>  	 * have i_mutex locked because it's not necessary.
>  	 */
> -	if (!(inode->i_state & (I_NEW|I_FREEING)))
> -		WARN_ON(!inode_is_locked(inode));
>  	trace_ext4_truncate_enter(inode);
>  
>  	if (!ext4_can_truncate(inode))
> diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
> index 0153c4d..1b6d22a 100644
> --- a/fs/ext4/namei.c
> +++ b/fs/ext4/namei.c
> @@ -3485,8 +3485,6 @@ int ext4_orphan_add(handle_t *handle, struct inode *inode)
>  	if (!sbi->s_journal || is_bad_inode(inode))
>  		return 0;
>  
> -	WARN_ON_ONCE(!(inode->i_state & (I_NEW | I_FREEING)) &&
> -		     !inode_is_locked(inode));
>  	/*
>  	 * Exit early if inode already is on orphan list. This is a big speedup
>  	 * since we don't have to contend on the global s_orphan_lock.
> @@ -3569,8 +3567,6 @@ int ext4_orphan_del(handle_t *handle, struct inode *inode)
>  	if (!sbi->s_journal && !(sbi->s_mount_state & EXT4_ORPHAN_FS))
>  		return 0;
>  
> -	WARN_ON_ONCE(!(inode->i_state & (I_NEW | I_FREEING)) &&
> -		     !inode_is_locked(inode));
>  	/* Do this quick check before taking global s_orphan_lock. */
>  	if (list_empty(&ei->i_orphan))
>  		return 0;
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/9e5d5f7a/attachment.sig>
