From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 23 Nov 2017 15:13:06 +0300
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: fixed signedness of
 some socklnd params
In-Reply-To: <20171122193831.11801-2-stefano.manni@gmail.com>
References: <20171122193831.11801-1-stefano.manni@gmail.com>
 <20171122193831.11801-2-stefano.manni@gmail.com>
Message-ID: <20171123121306.nu66ktiqjedongpp@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stefano Manni <stefano.manni@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Wed, Nov 22, 2017 at 08:38:28PM +0100, Stefano Manni wrote:
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
> index 5663a4c..2ad89ca 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
> @@ -43,7 +43,7 @@ MODULE_PARM_DESC(peer_timeout, "Seconds without aliveness news to declare peer d
>   * Number of daemons in each thread pool which is percpt,
>   * we will estimate reasonable value based on CPUs if it's not set.
>   */
> -static unsigned int nscheds;
> +static int nscheds;

I've looked through this series and I feel like none of these are real
bugs.  It's just about type safety and being consistent.  Which are good
things.  I'm not sure that I like the parts where we make the variables
signed.

Here "nscheds" is the number of threads.  How can we have a negative
number?  I think it should be unsigned.  It's way more tricky to change
the rest of the code, and leave nscheds unsigned int but I think it's
probably the right thing.

regards,
dan carpenter
