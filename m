From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 22 Jan 2018 11:37:45 +0100
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: Fix comment style
In-Reply-To: <1516413239.14739.0.camel@perches.com>
References: <20180115150259.GA17991@kroah.com>
 <1516290692-11642-1-git-send-email-fabian_huegel@web.de>
 <1516290692-11642-2-git-send-email-fabian_huegel@web.de>
 <1516413239.14739.0.camel@perches.com>
Message-ID: <20180122103745.GA23996@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: devel@driverdev.osuosl.org, Ben Evans <bevans@cray.com>, Fabian Huegel <fabian_huegel@web.de>, linux-kernel@i4.cs.fau.de, NeilBrown <neilb@suse.com>, linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, "John L . Hammond" <john.hammond@intel.com>, Lai Siyao <lai.siyao@intel.com>, Christoph Volkert <linux@christoph-volkert.de>

On Fri, Jan 19, 2018 at 05:53:59PM -0800, Joe Perches wrote:
> On Thu, 2018-01-18 at 16:51 +0100, Fabian Huegel wrote:
> > Most multi-line comments started on the first line, but the preferred
> > linux kernel style is to start multi-line comments on the second line.
> > Some comments became less readable after the change, so we changed them
> > to single-line comments.
> []
> > diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
> > 
> > @@ -182,7 +179,8 @@ struct config_llog_data {
> >  	struct obd_export	  *cld_mgcexp;
> >  	struct mutex		    cld_lock;
> >  	int			 cld_type;
> > -	unsigned int		cld_stopping:1, /* we were told to stop
> > +	unsigned int		cld_stopping:1, /*
> > +						 * we were told to stop
> >  						 * watching
> >  						 */
> >  				cld_lostlock:1; /* lock not requeued */
> 
> probably better for both of these to be bool
> instead of bitfield.

That's a change best left for a separate patch :)

thanks,

greg k-h
