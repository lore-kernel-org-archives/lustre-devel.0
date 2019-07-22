From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 14:13:37 +1000
Subject: [lustre-devel] [PATCH 01/22] ext4: add i_fs_version
In-Reply-To: <1563758631-29550-2-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-2-git-send-email-jsimmons@infradead.org>
Message-ID: <87wogapuz2.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> From: James Simmons <uja.ornl@yahoo.com>
>
> Add inode version field that osd-ldiskfs uses.

We need more words here.  What is i_fs_version used for?

(I'll probably find out as I keep reading, but I need to know
 the intention first, or I cannot properly review the patches
 that make use of it.
)
NeilBrown


>
> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> ---
>  fs/ext4/ext4.h   | 2 ++
>  fs/ext4/ialloc.c | 1 +
>  fs/ext4/inode.c  | 4 ++--
>  3 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> index 1cb6785..8abbcab 100644
> --- a/fs/ext4/ext4.h
> +++ b/fs/ext4/ext4.h
> @@ -1063,6 +1063,8 @@ struct ext4_inode_info {
>  	struct dquot *i_dquot[MAXQUOTAS];
>  #endif
>  
> +	u64 i_fs_version;
> +
>  	/* Precomputed uuid+inum+igen checksum for seeding inode checksums */
>  	__u32 i_csum_seed;
>  
> diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
> index 764ff4c..09ae4a4 100644
> --- a/fs/ext4/ialloc.c
> +++ b/fs/ext4/ialloc.c
> @@ -1100,6 +1100,7 @@ struct inode *__ext4_new_inode(handle_t *handle, struct inode *dir,
>  	ei->i_dtime = 0;
>  	ei->i_block_group = group;
>  	ei->i_last_alloc_group = ~0;
> +	ei->i_fs_version = 0;
>  
>  	ext4_set_inode_flags(inode);
>  	if (IS_DIRSYNC(inode))
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index c7f77c6..6e66175 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -4806,14 +4806,14 @@ static inline void ext4_inode_set_iversion_queried(struct inode *inode, u64 val)
>  	if (unlikely(EXT4_I(inode)->i_flags & EXT4_EA_INODE_FL))
>  		inode_set_iversion_raw(inode, val);
>  	else
> -		inode_set_iversion_queried(inode, val);
> +		EXT4_I(inode)->i_fs_version = val;
>  }
>  static inline u64 ext4_inode_peek_iversion(const struct inode *inode)
>  {
>  	if (unlikely(EXT4_I(inode)->i_flags & EXT4_EA_INODE_FL))
>  		return inode_peek_iversion_raw(inode);
>  	else
> -		return inode_peek_iversion(inode);
> +		return EXT4_I(inode)->i_fs_version;
>  }
>  
>  struct inode *__ext4_iget(struct super_block *sb, unsigned long ino,
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/4860f6d8/attachment.sig>
