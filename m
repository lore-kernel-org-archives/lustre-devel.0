From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 24 Jun 2017 00:12:58 +0800
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: lustre: several
 over 80 characters cleanups
In-Reply-To: <alpine.LFD.2.20.1706151704110.11322@casper.infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
	<1497452481-31124-6-git-send-email-jsimmons@infradead.org>
	<1497464128.18751.59.camel@perches.com>
	<alpine.LFD.2.20.1706151704110.11322@casper.infradead.org>
Message-ID: <20170623161258.GA20104@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Joe Perches <joe@perches.com>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Jun 15, 2017 at 05:06:30PM +0100, James Simmons wrote:
> 
> > On Wed, 2017-06-14 at 11:01 -0400, James Simmons wrote:
> > > Cleanup many of the over 80 characters reported by checkpatch
> > 
> > Please don't let checkpatch get in the way of lustre
> > readability.
> > 
> > lustre commonly uses very long identifiers.
> > Long identifiers and 80 columns don't mix well.
> > 
> > It might be simpler to declare in some document that
> > lustre uses lines of up to whatever length and require
> > that checkpatch should be used with the --max-line-length
> > option when run on lustre code.
> 
> Greg would you be okay with this? If we changed to a max-line-length to 
> say 128 thay would mean very few checkpatch issues would remain.

No, I don't want you go change the max-line-length, just use your best
judgement.  Some of the changes here in this very-big patch are just
fine, and should be done as they make the code easier to read.

Others, you are just having to fix pedantic things and there's no need
for that.  Let me give you a few examples in this patch of what I'm
talking about to help you understand the difference...

thanks,

greg k-h
