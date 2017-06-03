From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 3 Jun 2017 17:31:22 +0900
Subject: [lustre-devel] [PATCH] drivers: staging: lustre: lustre: llite:
 file.c - fixed sparse warning about different fmode_t type
In-Reply-To: <20170424102858.GA1471@gmail.com>
References: <20170424102858.GA1471@gmail.com>
Message-ID: <20170603083122.GA14332@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrea della Porta <sfaragnaus@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Mon, Apr 24, 2017 at 11:28:58AM +0100, Andrea della Porta wrote:
> Fixed the following sparse warning:
> 
>   CHECK   drivers/staging/lustre/lustre/llite//file.c
>   drivers/staging/lustre/lustre/llite//file.c:441:24: warning: incorrect
>   type in assignment (different base types)
>   drivers/staging/lustre/lustre/llite//file.c:441:24:    expected
>   restricted fmode_t [usertype] och_flags
>   drivers/staging/lustre/lustre/llite//file.c:441:24:    got unsigned
>   long long [unsigned] [usertype] it_flags
>   drivers/staging/lustre/lustre/llite//file.c:465:65: warning:
>   restricted fmode_t degrades to integer
>   drivers/staging/lustre/lustre/llite//file.c:465:22: warning: incorrect
>   type in assignment (different base types)
>   drivers/staging/lustre/lustre/llite//file.c:465:22:    expected
>   restricted fmode_t [usertype] fd_omode
>   drivers/staging/lustre/lustre/llite//file.c:465:22:    got unsigned
>   long long
>   drivers/staging/lustre/lustre/llite//file.c:526:38: warning: invalid
>   assignment: |=
>   drivers/staging/lustre/lustre/llite//file.c:526:38:    left side has
>   type unsigned long long
>   drivers/staging/lustre/lustre/llite//file.c:526:38:    right side has
>   type restricted fmode_t
>   drivers/staging/lustre/lustre/llite//file.c:533:49: warning:
>   restricted fmode_t degrades to integer
>   drivers/staging/lustre/lustre/llite//file.c:553:28: warning:
>   restricted fmode_t degrades to integer
>   drivers/staging/lustre/lustre/llite//file.c:556:35: warning:
>   restricted fmode_t degrades to integer
>   drivers/staging/lustre/lustre/llite//file.c:778:23: warning:
>   restricted fmode_t degrades to integer
>   drivers/staging/lustre/lustre/llite//file.c:1309:62: warning:
>   restricted fmode_t degrades to integer
>   drivers/staging/lustre/lustre/llite//file.c:1357:23: warning:
>   incorrect type in initializer (different base types)
>   drivers/staging/lustre/lustre/llite//file.c:1357:23:    expected
>   unsigned long long [unsigned] [usertype] flags
>   drivers/staging/lustre/lustre/llite//file.c:1357:23:    got restricted
>   fmode_t [usertype] <noident>

Please don't line-wrap messages like this so that we can see them
easier.

> Signed-off-by: Andrea della Porta <sfaragnaus@gmail.com>
> ---
>  drivers/staging/lustre/lustre/include/lustre_intent.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_intent.h b/drivers/staging/lustre/lustre/include/lustre_intent.h
> index ed2b6c6..c036633 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_intent.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_intent.h
> @@ -38,7 +38,7 @@
>  struct lookup_intent {
>  	int		it_op;
>  	int		it_create_mode;
> -	__u64		it_flags;
> +	fmode_t		it_flags;

This adds a bunch of new build warnings when appied, are you sure you
test-built your code?  Always do so, I can't take this patch as-is :(

thanks,

greg k-h
