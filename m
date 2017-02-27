From: Julia Lawall <julia.lawall@lip6.fr>
Date: Mon, 27 Feb 2017 22:25:23 +0100 (CET)
Subject: [lustre-devel] [Outreachy kernel] [PATCH 2/5] staging:
 rtl8192u: Remove unnecessary else after return
In-Reply-To: <1488219268-3006-2-git-send-email-singhalsimran0@gmail.com>
References: <1488219268-3006-1-git-send-email-singhalsimran0@gmail.com>
	<1488219268-3006-2-git-send-email-singhalsimran0@gmail.com>
Message-ID: <alpine.DEB.2.20.1702272224290.2127@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: simran singhal <singhalsimran0@gmail.com>
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org, outreachy-kernel@googlegroups.com



On Mon, 27 Feb 2017, simran singhal wrote:

> This patch fixes the checkpatch warning that else is not generally
> useful after a break or return.
>
> This was done using Coccinelle:
>
> @@
> expression e2;
> statement s1;
> @@
> if(e2) { ... return ...; }
> -else
>          s1
>
> Signed-off-by: simran singhal <singhalsimran0@gmail.com>
> ---
>  drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_tkip.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_tkip.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_tkip.c
> index 2453413..4d6c928 100644
> --- a/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_tkip.c
> +++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_tkip.c
> @@ -374,8 +374,7 @@ static int ieee80211_tkip_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
>
>  	if (!tcb_desc->bHwSec)
>  		return ret;
> -	else
> -		return 0;
> +	return 0;

In contrast to another patch I commented on, it seems likely that here 0
means success.  Converting 0 to false when that is what it means (ie not
here) makes the code more understandable.

julia
