From: Joe Perches <joe@perches.com>
Date: Thu, 15 Jun 2017 09:12:14 -0700
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: lustre: several
 over 80 characters cleanups
In-Reply-To: <alpine.LFD.2.20.1706151704110.11322@casper.infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
	<1497452481-31124-6-git-send-email-jsimmons@infradead.org>
	<1497464128.18751.59.camel@perches.com>
	<alpine.LFD.2.20.1706151704110.11322@casper.infradead.org>
Message-ID: <1497543134.14396.6.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, 2017-06-15 at 17:06 +0100, James Simmons wrote:
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
> Greg would you be okay with this?

I trust Greg isn't a zealot.

Linus Torvalds has said he prefers a longer line length
(up to 100 cols)

https://lkml.org/lkml/2016/12/15/749

> If we changed to a max-line-length to 
> say 128 thay would mean very few checkpatch issues would remain.
