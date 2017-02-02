From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 2 Feb 2017 11:43:57 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: shut up clang warnings
	on CLASSERT()
In-Reply-To: <CAK8P3a1oT+yp_kP-faQMdVun7ny9gfSpby3Ae0xmEpzmuGEJCA@mail.gmail.com>
References: <20170201165314.2588373-1-arnd@arndb.de>
	<C39A7DE9-5D89-4B98-A61F-1BB766ADEFC0@intel.com>
	<20170202095453.GA30437@kroah.com>
	<CAK8P3a1oT+yp_kP-faQMdVun7ny9gfSpby3Ae0xmEpzmuGEJCA@mail.gmail.com>
Message-ID: <20170202104357.GB22904@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Dilger, Andreas" <andreas.dilger@intel.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, "Eremin, Dmitry" <dmitry.eremin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 02, 2017 at 11:40:32AM +0100, Arnd Bergmann wrote:
> On Thu, Feb 2, 2017 at 10:54 AM, Greg Kroah-Hartman
> <gregkh@linuxfoundation.org> wrote:
> b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> >> > index aab15d8112a4..2d5435029185 100644
> >> > --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> >> > +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> >> > @@ -291,7 +291,7 @@ do {                                                        \
> >> >  *       value  after  conversion...
> >> >  *
> >> >  */
> >> > -#define CLASSERT(cond) do {switch (42) {case (cond): case 0: break; } } while (0)
> >> > +#define CLASSERT(cond) do {switch (42) {case (cond): case 0: default: break; } } while (0)
> >
> > Ugh, why not just use the in-kernel ASSERT macro instead?
> 
> We don't have one ;-)

Oh nice!

> I've done a semi-automated patch to replace CLASSERT() with the respective
> BUILD_BUG_ON() now, but that patch is quite large.

Should be easy to script, I missed that this was a build-time check.
Heck, I'll take a script to do this, or I can just do it in my end.

thanks,

greg k-h
