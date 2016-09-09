From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Fri, 09 Sep 2016 01:45:39 -0000
Subject: [lustre-devel] [PATCH] staging/lustre/lov: add missing header
	dependencies
In-Reply-To: <alpine.LFD.2.20.1609081851520.14646@casper.infradead.org>
References: <1473324508-9294-1-git-send-email-baoyou.xie@linaro.org>
	<alpine.LFD.2.20.1609081851520.14646@casper.infradead.org>
Message-ID: <CA+DQWkx=_J6FmWgPN2UbnprvM1KzpnEE3kgbkWY1pcAxk1jqMg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Looks like it's better to clean it up :)

On 9 September 2016 at 01:59, James Simmons <jsimmons@infradead.org> wrote:

>
> > We get 1 warning when building kernel with W=1:
> > drivers/staging/lustre/lustre/lov/lov_object.c:956:23: warning: no
> previous prototype for 'lov_lsm_get' [-Wmissing-prototypes]
> > drivers/staging/lustre/lustre/lov/lov_object.c:972:6: warning: no
> previous prototype for 'lov_lsm_put' [-Wmissing-prototypes]
> > drivers/staging/lustre/lustre/lov/lov_object.c:979:5: warning: no
> previous prototype for 'lov_read_and_clear_async_rc' [-Wmissing-prototypes]
> >
> > In fact, these functions are declared in ../llite/vvp_internal.h,
> > so this patch add missing header dependencies.
> >
> > Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
>
> Nak. The header vvp_internal.h is meant to private to the llite layer.
> Looking at the coming patch updates I see lov_lsm_[put|get] will not be
> used in the lov later. Now lov_read_and_clear_async is still used in
> both layers. The header used for this case is cl_object.h. Might rename
> that function to be consistent with the rest of the header. I will look
> into a cleanup for this.
>
> > ---
> >  drivers/staging/lustre/lustre/lov/lov_object.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c
> b/drivers/staging/lustre/lustre/lov/lov_object.c
> > index f9621b0..912c416 100644
> > --- a/drivers/staging/lustre/lustre/lov/lov_object.c
> > +++ b/drivers/staging/lustre/lustre/lov/lov_object.c
> > @@ -38,6 +38,7 @@
> >  #define DEBUG_SUBSYSTEM S_LOV
> >
> >  #include "lov_cl_internal.h"
> > +#include "../llite/vvp_internal.h"
> >
> >  /** \addtogroup lov
> >   *  @{
> > --
> > 2.7.4
> >
> > _______________________________________________
> > devel mailing list
> > devel at linuxdriverproject.org
> > http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
> >
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160909/4f158d1a/attachment-0001.htm>
