From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 28 Apr 2017 09:30:31 +0200
Subject: [lustre-devel] [PATCH] drivers: staging: lustre: lustre: llite:
 file.c - fixed sparse warning about different fmode_t type
In-Reply-To: <20170424065311.GA32527@gmail.com>
References: <20170424065311.GA32527@gmail.com>
Message-ID: <20170428073031.GB29107@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrea della Porta <sfaragnaus@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Mon, Apr 24, 2017 at 07:53:11AM +0100, Andrea della Porta wrote:
> fixed a couple of sparse warning complaining about type mismatch.

That's really vague, please be specific.

> 
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

Are you sure?  Why?  What exact warning did this "fix"?

thanks,

greg k-h
