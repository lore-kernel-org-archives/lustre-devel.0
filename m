From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 24 Jun 2015 14:37:51 +0200
Subject: [lustre-devel] [PATCH v4 4/9] staging:lustre: merge
	socklnd_lib-linux.h into socklnd.h
In-Reply-To: <1434050295-10986-5-git-send-email-jsimmons@infradead.org>
References: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
	<1434050295-10986-5-git-send-email-jsimmons@infradead.org>
Message-ID: <CAMuHMdV6e_0qKkAVwAuyFFMhGxqW5ekifEyKiZevRahgu+ozWQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi James,

On Thu, Jun 11, 2015 at 9:18 PM, James Simmons <jsimmons@infradead.org> wrote:
> From: John L. Hammond <john.hammond@intel.com>
>
> Originally socklnd_lib-linux.h contained linux specific
> wrappers and defines but since the linux kernel is the
> only supported platform now we can merge what little
> remains in the header into socklnd.h. This is broken
> out of the original patch 12932 that was merged to the
> Intel/OpenSFS branch.
>
> Signed-off-by: John L. Hammond <john.hammond@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
> Reviewed-on: http://review.whamcloud.com/12932
> Reviewed-by: Isaac Huang <he.huang@intel.com>
> Reviewed-by: James Simmons <uja.ornl@gmail.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   39 +++++++++-
>  .../lustre/lnet/klnds/socklnd/socklnd_lib-linux.h  |   86 --------------------
>  .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    4 +-
>  3 files changed, 40 insertions(+), 89 deletions(-)
>  delete mode 100644 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.h
>
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> index 53275f9..7125eb9 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> @@ -25,16 +25,40 @@
>   *
>   */
>
> +#ifndef _SOCKLND_SOCKLND_H_
> +#define _SOCKLND_SOCKLND_H_
> +
>  #define DEBUG_PORTAL_ALLOC
>  #define DEBUG_SUBSYSTEM S_LND
>
> -#include "socklnd_lib-linux.h"
> +#include <asm/irq.h>
> +#include <linux/crc32.h>
> +#include <linux/errno.h>

Including <asm/irq.h> first causes a build failure for m68k/allmodconfig:

arch/m68k/include/asm/irq.h:77:12: error: expected '=', ',', ';',
'asm' or '__attribute__' before 'void'
arch/m68k/include/asm/irq.h:78:1: error: unknown type name 'atomic_t'
arch/m68k/include/asm/irq.h:77:12: error: expected '=', ',', ';',
'asm' or '__attribute__' before 'void'
arch/m68k/include/asm/irq.h:78:1: error: unknown type name 'atomic_t'

http://kisskb.ellerman.id.au/kisskb/buildresult/12448922/

Fixing it inside arch/m68k/include/asm/irq.h might cause Include Hell,
so perhaps you can just move the <asm/*> include below all <linux/*>
includes?

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert at linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
