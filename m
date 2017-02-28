From: Julia Lawall <julia.lawall@lip6.fr>
Date: Tue, 28 Feb 2017 20:19:28 +0100 (CET)
Subject: [lustre-devel] [Outreachy kernel] [PATCH 3/5] staging: rtl8712:
 Remove unnecessary else after return
In-Reply-To: <CALrZqyPqNUCdbEpQT2KkGS8F8Up6d_Uc56YHVLxf_QDFghooWw@mail.gmail.com>
References: <1488219268-3006-1-git-send-email-singhalsimran0@gmail.com>
	<1488219268-3006-3-git-send-email-singhalsimran0@gmail.com>
	<alpine.DEB.2.20.1702272216140.2127@hadrien>
	<CALrZqyPqNUCdbEpQT2KkGS8F8Up6d_Uc56YHVLxf_QDFghooWw@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1702282019110.2171@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: SIMRAN SINGHAL <singhalsimran0@gmail.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org, outreachy-kernel@googlegroups.com



On Wed, 1 Mar 2017, SIMRAN SINGHAL wrote:

> On Tue, Feb 28, 2017 at 2:49 AM, Julia Lawall <julia.lawall@lip6.fr> wrote:
> >
> >
> > On Mon, 27 Feb 2017, simran singhal wrote:
> >
> >> This patch fixes the checkpatch warning that else is not generally
> >> useful after a break or return.
> >>
> >> This was done using Coccinelle:
> >> @@
> >> expression e2;
> >> statement s1;
> >> @@
> >> if(e2) { ... return ...; }
> >> -else
> >>          s1
> >
> > One might be surprised that the following code was detected using the
> > above semantic patch, because in the code below there is no return in the
> > if branches.  Actually, as a special feature, when one has an if branch
> > that ends in return, Coccinelle will skip through any gotos and see if the
> > return is matched afterward.  Indeed it is a common pattern to have
> >
> > if (...) {
> >    foo(x);
> >    bar(y);
> >    return -ENOMEM;
> > }
> >
> > But the code can also be cut up as eg
> >
> > if (...) {
> >    ret = -ENOMEM;
> >    goto out;
> > }
> > ...
> > out:
> >    foo(x);
> >    bar(y);
> >    return ret;
> >
> > To avoid having to write multiple patterns for these cases, Coccinelle
> > will just jump through the return in the second case, allowing the same
> > pattern to match both of them.
> >
> Julia, Thanks for explaination. Its really helpful.
>
> But I think there is no problem in removing else.
> Because it will execute this
>
>  padapter->dvobjpriv.inirp_init(padapter);
>
> when if condition will not satisfy.

It seems ok to me.

julia

>
> > julia
> >
> >>
> >> Signed-off-by: simran singhal <singhalsimran0@gmail.com>
> >> ---
> >>  drivers/staging/rtl8712/os_intfs.c | 3 +--
> >>  1 file changed, 1 insertion(+), 2 deletions(-)
> >>
> >> diff --git a/drivers/staging/rtl8712/os_intfs.c b/drivers/staging/rtl8712/os_intfs.c
> >> index 8836b31..3062167 100644
> >> --- a/drivers/staging/rtl8712/os_intfs.c
> >> +++ b/drivers/staging/rtl8712/os_intfs.c
> >> @@ -411,8 +411,7 @@ static int netdev_open(struct net_device *pnetdev)
> >>                       goto netdev_open_error;
> >>               if (!padapter->dvobjpriv.inirp_init)
> >>                       goto netdev_open_error;
> >> -             else
> >> -                     padapter->dvobjpriv.inirp_init(padapter);
> >> +             padapter->dvobjpriv.inirp_init(padapter);
> >>               r8712_set_ps_mode(padapter, padapter->registrypriv.power_mgnt,
> >>                                 padapter->registrypriv.smart_ps);
> >>       }
> >> --
> >> 2.7.4
> >>
> >> --
> >> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> >> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe at googlegroups.com.
> >> To post to this group, send email to outreachy-kernel at googlegroups.com.
> >> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/1488219268-3006-3-git-send-email-singhalsimran0%40gmail.com.
> >> For more options, visit https://groups.google.com/d/optout.
> >>
>
