From: Julia Lawall <julia.lawall@lip6.fr>
Date: Tue, 28 Feb 2017 20:21:44 +0100 (CET)
Subject: [lustre-devel] [Outreachy kernel] Re: [PATCH 5/5] staging:
 gdm724x: Remove unnecessary else after return
In-Reply-To: <1488309512.25838.32.camel@perches.com>
References: <1488219268-3006-1-git-send-email-singhalsimran0@gmail.com>
	<1488219268-3006-5-git-send-email-singhalsimran0@gmail.com>
	<1488224468.25838.11.camel@perches.com>
	<CALrZqyMy3q1GOj3uDK3VpXCs4rNrX2R7WM5wHgFXQTaH-U0utA@mail.gmail.com>
	<CALrZqyMUbKUO4it-kmDGwaZJS8b4hrpihDf7jpGPaRmN4_hOzg@mail.gmail.com>
	<1488309512.25838.32.camel@perches.com>
Message-ID: <alpine.DEB.2.20.1702282019580.2171@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: SIMRAN SINGHAL <singhalsimran0@gmail.com>, Greg KH <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org, outreachy-kernel@googlegroups.com



On Tue, 28 Feb 2017, Joe Perches wrote:

> On Wed, 2017-03-01 at 00:41 +0530, SIMRAN SINGHAL wrote:
> > On Tue, Feb 28, 2017 at 1:49 AM, SIMRAN SINGHAL
> > <singhalsimran0@gmail.com> wrote:
> > > On Tue, Feb 28, 2017 at 1:11 AM, Joe Perches <joe@perches.com> wrote:
> > > > On Mon, 2017-02-27 at 23:44 +0530, simran singhal wrote:
> > > > > This patch fixes the checkpatch warning that else is not generally
> > > > > useful after a break or return.
> > > > > This was done using Coccinelle:
> > > > > @@
> > > > > expression e2;
> > > > > statement s1;
> > > > > @@
> > > > > if(e2) { ... return ...; }
> > > > > -else
> > > > >          s1
> > > >
> > > > []
> > > > > diff --git a/drivers/staging/gdm724x/gdm_endian.c b/drivers/staging/gdm724x/gdm_endian.c
> > > >
> > > > []
> > > > > @@ -26,30 +26,26 @@ __dev16 gdm_cpu_to_dev16(struct gdm_endian *ed, u16 x)
> > > > >  {
> > > > >       if (ed->dev_ed == ENDIANNESS_LITTLE)
> > > > >               return (__force __dev16)cpu_to_le16(x);
> > > > > -     else
> > > > > -             return (__force __dev16)cpu_to_be16(x);
> > > > > +     return (__force __dev16)cpu_to_be16(x);
> > > >
> > > > again, not a checkpatch message for any of the
> > > > suggested modified hunks.
> > > >
> >
> > I am not getting what's the problem in removing else or may be I
> > am wrong you just want to say that I should change the commit message.
>
> 2 things:
>
> 1: The commit message is incorrect.
> 2: This form is fundamentally OK:
>
> 	if (foo)
> 		return bar;
> 	else
> 		return baz;
>
>
> So I think this patch is not good.

I agree in this case.  The two branches are quite parallel.  In some of
the other patches, the if was looking for the absence of some resource or
the failure of something, so there was a clear distinction between one
branch being cleanup on failure and the other branch being the continuing
successful computation, even if it is just to return a success indicator.

julia
