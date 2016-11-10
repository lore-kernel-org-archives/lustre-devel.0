From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 17:53:31 +0000 (GMT)
Subject: [lustre-devel] [PATCH] staging: lustre: ldlm: pl_recalc time
 handling is wrong
In-Reply-To: <5149342.oboLeYkUcs@wuerfel>
References: <1478573240-12850-1-git-send-email-jsimmons@infradead.org>
	<1594836.LAbS3nYoXQ@wuerfel> <20161110122108.GA7580@kroah.com>
	<5149342.oboLeYkUcs@wuerfel>
Message-ID: <alpine.LFD.2.20.1611101750010.31600@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Thursday, November 10, 2016 1:21:08 PM CET Greg Kroah-Hartman wrote:
> > > 
> > > the intention here is simply to have the console log keep the
> > > same numbers as "date +%s" for absolute values. The patch that
> > > James suggested converting everything to ktime_get_seconds()
> > > would result in the same intervals that have always been there
> > > (until I broke it by using time domains inconsistently), but
> > > would mean we could use a u32 type for pl_recalc_time and
> > > pl_recalc_period because that doesn't overflow until 136 years
> > > after booting. (signed time_t overflows 68 years after 1970,
> > > i.e 2038).
> > 
> > So, is this patch correct and should be merged to the tree, or not?
> > 
> 
> No, I think it's wrong in a different way as before. After my
> patch, there were six instances of ktime_get_real_seconds() and
> three instances of ktime_get_seconds(), and that was wrong.
> 
> James's patch converts three of the six instances to
> ktime_get_seconds(), which is equally wrong, just different.
> 
> We can either convert the six ktime_get_real_seconds()
> to ktime_get_seconds(), or convert the four (one was added
> in the meantime) ktime_get_seconds() to ktime_get_real_seconds().
> 
> I'll follow up with a patch for the latter as it is what I
> had originally intended. We can also do what James intended
> instead.

I tought about it and yes ktime_get_real_seconds() is the
right way to go due to the debug message. Especially if the
node happens to reboot. Having a debug message after a reboot
with a smaller time reported in the debug message compared to
a earlier debug message might be confusing to someone.
