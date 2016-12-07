From: James Simmons <jsimmons@infradead.org>
Date: Wed, 7 Dec 2016 19:57:13 +0000 (GMT)
Subject: [lustre-devel] Remaining work needed for moving Lustre out of
 staging
In-Reply-To: <EDDB386E-5258-4BF4-93A6-BF2D365756F4@dilger.ca>
References: <1E1B324A-F545-417D-9C35-550FA58665C7@intel.com>
	<20161203085550.GA5375@kroah.com>
	<0F617FFB-4BD0-4477-890B-2CDC56436DCC@intel.com>
	<20161206161524.GA5535@kroah.com>
	<7AF464A9-1D0F-48E9-B83C-66F983268473@intel.com>
	<EDDB386E-5258-4BF4-93A6-BF2D365756F4@dilger.ca>
Message-ID: <alpine.LFD.2.20.1612071953050.1427@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Dilger <adilger@dilger.ca>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg KH <gregkh@linuxfoundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "lustre-devel@lists.lustre.org List" <lustre-devel@lists.lustre.org>


> > On the warning front, we have 879 line over 80 characters, but a bunch
> > of those are due to long error messages that we cannot split into a multiline thing anyway.
> > 71 Prefer 'unsigned int' to bare use of 'unsigned' that is a relatively new one
> > 22 new typedefs (all in lnet, I drove out all the lustre ones, so I guess I can tackle these too).
> 
> I think James already has a patch series getting rid of typedefs from LNet?

I created a big patch some time ago but I need to break it into smaller 
pieces. We should sync our tools to be able to build against these changes
as well. I pushed patches to change our tools.
