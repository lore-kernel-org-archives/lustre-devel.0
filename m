From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 14:37:00 +1000
Subject: [lustre-devel] [PATCH 06/22] ext4: add extra checks for mballoc
In-Reply-To: <1563758631-29550-7-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-7-git-send-email-jsimmons@infradead.org>
Message-ID: <87lfwqptw3.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> Handle mballoc corruptions.

"Handle" here mean "return -EIO if corruptions are found" ??

Sounds like a good thing to do.  I cannot comment on the code without
understand the fs more, but...

> diff --git a/fs/ext4/mballoc.h b/fs/ext4/mballoc.h
> index 88c98f1..8325ad9 100644
> --- a/fs/ext4/mballoc.h
> +++ b/fs/ext4/mballoc.h
> @@ -70,7 +70,7 @@
>  /*
>   * for which requests use 2^N search using buddies
>   */
> -#define MB_DEFAULT_ORDER2_REQS		2
> +#define MB_DEFAULT_ORDER2_REQS		8

I don't think this belongs with the reset of the patch.

NeilBrown


>  
>  /*
>   * default group prealloc size 512 blocks
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/59f2a4c0/attachment.sig>
