From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 15:06:49 +1000
Subject: [lustre-devel] [PATCH 11/22] ext4: over ride current_time
In-Reply-To: <1563758631-29550-12-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-12-git-send-email-jsimmons@infradead.org>
Message-ID: <87a7d6psie.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> return i_ctime if IS_NOCMTIME is true for inode.

So ... this prevents ext4 from ever changing the i_ctime
on any file with S_NOCMTIME set - and osd-ldiskfs sets that on
all inodes.

Presumably osd wants full control of the ctime.

That's probably a reasonable goal.  I think it should be achieved by
adding a mount/sb flag which suppresses all m/ctime updates except those
made through utimes().

NeilBrown


>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  fs/ext4/ext4.h | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> index 51b6159..80601a9 100644
> --- a/fs/ext4/ext4.h
> +++ b/fs/ext4/ext4.h
> @@ -661,6 +661,13 @@ enum {
>  #define EXT4_GOING_FLAGS_LOGFLUSH		0x1	/* flush log but not data */
>  #define EXT4_GOING_FLAGS_NOLOGFLUSH		0x2	/* don't flush log nor data */
>  
> +static inline struct timespec64 ext4_current_time(struct inode *inode)
> +{
> +	if (IS_NOCMTIME(inode))
> +		return inode->i_ctime;
> +	return current_time(inode);
> +}
> +#define current_time(a) ext4_current_time(a)
>  
>  #if defined(__KERNEL__) && defined(CONFIG_COMPAT)
>  /*
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/6cddc8bd/attachment.sig>
