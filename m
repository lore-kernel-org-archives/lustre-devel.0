From: Joe Perches <joe@perches.com>
Date: Thu, 29 Jun 2017 20:37:05 -0700
Subject: [lustre-devel] [PATCH v2] staging: lustre: lnet: remove dead
 code and crc32_le() wrapper
In-Reply-To: <1498793366-10539-1-git-send-email-dmitriy@oss-tech.org>
References: <1498711356-14270-1-git-send-email-dmitriy@oss-tech.org>
	<1498793366-10539-1-git-send-email-dmitriy@oss-tech.org>
Message-ID: <1498793825.2739.10.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitriy Cherkasov <dmitriy@oss-tech.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, 2017-06-30 at 03:29 +0000, Dmitriy Cherkasov wrote:
> After removing code which was premanently disabled with ifdefs, the
> function ksocknal_csum() becomes just a wrapper for crc32_le(). Remove
> this useless wrapper and instead call crc32_le() directly.
> 
> This also resolves the following checkpatch warning which was
> triggered by the dead code:
> 
> WARNING: space prohibited before semicolon

Please use checkpatch on your proposed patches before
sending them.

> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
[]
> @@ -201,7 +201,7 @@
>  			if (fragnob > sum)
>  				fragnob = sum;
>  
> -			conn->ksnc_rx_csum = ksocknal_csum(conn->ksnc_rx_csum,
> +			conn->ksnc_rx_csum = crc32_le(conn->ksnc_rx_csum,
>  							   iov[i].iov_base,
>  							   fragnob);

Please realign the subsequent lines to the open parenthesis.

>  		}
> @@ -243,7 +243,7 @@
>  			if (fragnob > sum)
>  				fragnob = sum;
>  
> -			conn->ksnc_rx_csum = ksocknal_csum(conn->ksnc_rx_csum,
> +			conn->ksnc_rx_csum = crc32_le(conn->ksnc_rx_csum,
>  							   base, fragnob);

etc...
