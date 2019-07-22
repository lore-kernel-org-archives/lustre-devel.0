From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 15:27:08 +1000
Subject: [lustre-devel] [PATCH 17/22] ext4: optimize
 ext4_journal_callback_add
In-Reply-To: <1563758631-29550-18-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-18-git-send-email-jsimmons@infradead.org>
Message-ID: <87sgqyod03.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> Change list_add_tail to list_add. It gives advantages to ldiskfs
> in tgt_cb_last_committed. In the beginning of list will be placed
> thandles with the highest transaction numbers. So at the first
> iterations we will have the highest transno. It will save from
> extra call of ptlrpc_commit_replies.

If only more commit messages were like this !!  Thanks!

I suspect it would be better for that thing that needs to see the
highest transno first, to find a way to look at the end of the list
instead of the beginning.

This isn't the sort of change that can land in ext4.

NeilBrown


>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  fs/ext4/ext4_jbd2.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/ext4/ext4_jbd2.h b/fs/ext4/ext4_jbd2.h
> index 75a5309..5ebf8ee 100644
> --- a/fs/ext4/ext4_jbd2.h
> +++ b/fs/ext4/ext4_jbd2.h
> @@ -169,7 +169,7 @@ static inline void _ext4_journal_callback_add(handle_t *handle,
>  			struct ext4_journal_cb_entry *jce)
>  {
>  	/* Add the jce to transaction's private list */
> -	list_add_tail(&jce->jce_list, &handle->h_transaction->t_private_list);
> +	list_add(&jce->jce_list, &handle->h_transaction->t_private_list);
>  }
>  
>  static inline void ext4_journal_callback_add(handle_t *handle,
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/2504564a/attachment.sig>
