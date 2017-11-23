From: Tobin C. Harding <me@tobin.cc>
Date: Thu, 23 Nov 2017 15:59:26 +1100
Subject: [lustre-devel] [PATCH 0/4] staging: lustre: fixed some
 signedness warns from sparse
In-Reply-To: <20171122193831.11801-1-stefano.manni@gmail.com>
References: <20171122193831.11801-1-stefano.manni@gmail.com>
Message-ID: <20171123045926.GD12736@eros>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stefano Manni <stefano.manni@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Wed, Nov 22, 2017 at 08:38:27PM +0100, Stefano Manni wrote:
> Fixed some signedness warnings from sparse on lustre.
> 
> Stefano Manni (4):
>   staging: lustre: fixed signedness of some socklnd params
>   staging: lustre: fixed signedness of llite
>   staging: lustre: fixed signedness of lov
>   staging: lustre: fixed signedness of obdclass

You may like to use imperative mood for your git log brief descriptions
Stefano.  

s/fixed/fix/

For justification see Documentation/process/submitting-patches.rst.

Specifically section 2 of that document.

Hope this helps,
Tobin.


>  drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h        |  4 ++--
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c  |  2 +-
>  drivers/staging/lustre/lustre/llite/dir.c                  |  3 ++-
>  drivers/staging/lustre/lustre/llite/llite_lib.c            |  9 ++++++---
>  drivers/staging/lustre/lustre/llite/lproc_llite.c          | 14 ++++++--------
>  drivers/staging/lustre/lustre/lov/lov_obd.c                |  2 +-
>  drivers/staging/lustre/lustre/lov/lov_offset.c             | 11 +++++++----
>  drivers/staging/lustre/lustre/obdclass/obd_mount.c         |  2 +-
>  8 files changed, 26 insertions(+), 21 deletions(-)
> 
> -- 
> 2.5.5
> 
> _______________________________________________
> devel mailing list
> devel at linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
