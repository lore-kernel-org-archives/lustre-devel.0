From: Tobin Harding <me@tobin.cc>
Date: Mon, 23 May 2016 10:20:07 +1000
Subject: [lustre-devel] [PATCH] staging: lustre: llite:
 kzalloc/copy_to_user to memdup_user
In-Reply-To: <20160522222538.GA17573@kroah.com>
References: <1463953771-16942-1-git-send-email-me@tobin.cc>
	<20160522222538.GA17573@kroah.com>
Message-ID: <20160523002007.GA14493@eros.local>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Dmitry Eremin <dmitry.eremin@intel.com>, Abdul Hussain <habdul@visteon.com>, Andreas Dilger <andreas.dilger@intel.com>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, James Nunez <james.a.nunez@intel.com>, patrik.r.jakobsson@gmail.com, linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, Julia Lawall <Julia.Lawall@lip6.fr>, Al Viro <viro@zeniv.linux.org.uk>, "John L. Hammond" <john.hammond@intel.com>, Frank Zago <fzago@cray.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, lustre-devel@lists.lustre.org

On Sun, May 22, 2016 at 03:25:38PM -0700, Greg Kroah-Hartman wrote:
> On Mon, May 23, 2016 at 07:49:29AM +1000, Tobin C Harding wrote:
> > kzalloc call followed by copy_to_user can be replaced by call to memdup_user.
> > 
> > Signed-off-by: Tobin C Harding <me@tobin.cc>
>
> Why did you send this twice?

Because I'm a git send-email amateur.

> > ---
> >  drivers/gpu/drm/gma500/gma_display.c      |  2 +-
> >  drivers/staging/lustre/lustre/llite/dir.c | 22 +++++++---------------
> >  2 files changed, 8 insertions(+), 16 deletions(-)
> > 
> > diff --git a/drivers/gpu/drm/gma500/gma_display.c b/drivers/gpu/drm/gma500/gma_display.c
> > index 5bf765d..8a1fb25 100644
> > --- a/drivers/gpu/drm/gma500/gma_display.c
> > +++ b/drivers/gpu/drm/gma500/gma_display.c
> > @@ -285,7 +285,7 @@ void gma_crtc_dpms(struct drm_crtc *crtc, int mode)
> >  
> >             /* Wait for vblank for the disable to take effect */
> >             gma_wait_for_vblank(dev);
> > -
> > +l
>
> What?  What does this have to do with lustre?

Turns out I'm a git amateur in general, the gma_display changes should not have
been committed on this branch.

> It's kind of obvious you didn't build this :(

Epic fail.

> Please be more careful in the future.
>
> greg k-h

I am humbly attempting to learn the way of kernel dev, thank you for your
patience, I will endeavor to be more careful.

Regards,
Tobin Harding.
