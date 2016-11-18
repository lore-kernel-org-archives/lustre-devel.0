From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 18 Nov 2016 18:14:26 +0100
Subject: [lustre-devel] [PATCH 32/35] staging: lustre: mount: fix
 lmd_parse() to handle commas in expr_list
In-Reply-To: <alpine.LFD.2.20.1611181650440.3854@casper.infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
	<1478799065-24841-33-git-send-email-jsimmons@infradead.org>
	<20161114151246.GA29168@kroah.com>
	<alpine.LFD.2.20.1611181650440.3854@casper.infradead.org>
Message-ID: <20161118171426.GA24226@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jian Yu <jian.yu@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Nov 18, 2016 at 04:54:03PM +0000, James Simmons wrote:
> 
> > > --- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> > > +++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> > > @@ -871,6 +871,87 @@ static int lmd_parse_mgs(struct lustre_mount_data *lmd, char **ptr)
> > >  	return 0;
> > >  }
> > >  
> > > +/**
> > > + * Find the first comma delimiter from the specified \a buf and make \a *endh
> > > + * point to the string starting with the comma. The commas in expression list
> > > + * [...] will be skipped.
> > > + *
> > > + * \param[in] buf	a comma-separated string
> > > + * \param[in] endh	a pointer to a pointer that will point to the string
> > > + *			starting with the comma
> > 
> > Please drop this mess of \param, it's not needed and is not kernel-doc
> > format.
> 
> Is it just the [in] mess that needs to be removed or does the doc style
> need to migrate to another format. Looking online doesn't reveal much and'
> I saw something about @arg format as well. I see both in tree. What is the
> right one to use and do clear docs on this format exist somewhere.

@arg is the correct one, see the file
Documentation/kernel-documentation.rst in the section, "How to format
kernel-doc comments" for how to do this properly.

thanks,

greg k-h
