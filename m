From: James Simmons <jsimmons@infradead.org>
Date: Wed, 8 Jun 2016 18:46:21 +0100 (BST)
Subject: [lustre-devel] [PATCH 0/2] *** staging: lustre: Replace
 semaphore lock with mutex ***
In-Reply-To: <1465372242-7116-1-git-send-email-binoy.jayan@linaro.org>
References: <1465372242-7116-1-git-send-email-binoy.jayan@linaro.org>
Message-ID: <alpine.LFD.2.20.1606081843450.30765@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Binoy Jayan <binoy.jayan@linaro.org>
Cc: Andreas Dilger <andreas.dilger@intel.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, lustre-devel@lists.lustre.org


> Hi,
> 
> These are a set of patches which removes semaphores from:
> 
> drivers/staging/lustre  (lnet)
> 
> These are part of a bigger effort to eliminate all semaphores 
> from the linux kernel.
> 
> They build correctly (individually and as a whole).
> 
> Thanks,
> Binoy

I just finishing running the latest staging tree againt our
test suite so I'm going to look to testing your patch next.
 
> Binoy Jayan (2):
>   staging: lustre: lloop_device: Replace semaphore lo_sem with
>     completion

This patch can be dropped. I will be shortly submitting a patch
to remove the lloop back device. 

>   staging: lustre: lnet: Replace semaphore ln_rc_signal with completion

Will send a ack once I'm done testing.

>  drivers/staging/lustre/include/linux/lnet/lib-types.h |  3 ++-
>  drivers/staging/lustre/lnet/lnet/router.c             |  9 +++++----
>  drivers/staging/lustre/lustre/llite/lloop.c           | 14 +++++++-------
>  3 files changed, 14 insertions(+), 12 deletions(-)
> 
> -- 
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
> a Linux Foundation Collaborative Project
> 
> _______________________________________________
> devel mailing list
> devel at linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
> 
