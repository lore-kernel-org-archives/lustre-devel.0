From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Nov 2016 17:27:00 +0000 (GMT)
Subject: [lustre-devel] [PATCH v4] staging: lustre: mdc: manage number
 of modify RPCs in flight
In-Reply-To: <20161114172047.GA4989@kroah.com>
References: <1478793073-21814-1-git-send-email-jsimmons@infradead.org>
	<20161114151737.GA18183@kroah.com>
	<alpine.LFD.2.20.1611141656220.29600@casper.infradead.org>
	<20161114172047.GA4989@kroah.com>
Message-ID: <alpine.LFD.2.20.1611141722160.29600@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Gregoire Pichon <gregoire.pichon@bull.net>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Mon, Nov 14, 2016 at 04:59:48PM +0000, James Simmons wrote:
> > 
> > > On Thu, Nov 10, 2016 at 10:51:13AM -0500, James Simmons wrote:
> > > > From: Gregoire Pichon <gregoire.pichon@bull.net>
> > > > 
> > > > This patch is the main client part of a new feature that supports
> > > > multiple modify metadata RPCs in parallel. Its goal is to improve
> > > > metadata operations performance of a single client, while maintening
> > > > the consistency of MDT reply reconstruction and MDT recovery
> > > > mechanisms.
> > > > 
> > > > It allows to manage the number of modify RPCs in flight within
> > > > the client obd structure and to assign a virtual index (the tag) to
> > > > each modify RPC to help server side cleaning of reply data.
> > > > 
> > > > The mdc component uses this feature to send multiple modify RPCs
> > > > in parallel.
> > > 
> > > Is this a new feature?  Why should we take this now and not just wait
> > > until the code is out of staging?
> > 
> > Yes on the server side. So the problem on our meta data servers couldn't
> > handle writing mulitiple bits of data to the back end disk at ths same
> > time.
> > 
> > One client side the issue was the metadata operations were being 
> > serialized by a mutex in the MDC layer. That is what this patch fixed.
> > So for the client it would be a performance improvement patch. 
> 
> So, it's a "performance" patch, which isn't functionality, so why should
> we merge this to staging now?  Why aren't people working on the known
> coding issues to get this out of staging instead of working on
> performance stuff?

Because the primary goal which the people at my company, not Intel by 
the way, wanted was to get this to what is running in production 
environments so people would actually use the staging client. When it was 
old and broken no one would touch it with a 10 foot pole. The currently 
supported verison in production is lustre 2.8.0 so we are only about 30 
patches away from reaching the goal. I'm going to respond to your other
email in length about leaving staging. It would be really nice for the
user base if we can reach that goal.
