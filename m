From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 16:52:46 +0100 (BST)
Subject: [lustre-devel] [PATCH 13/17] staging: lustre: lloop: Fix build
 failure on ppc64
In-Reply-To: <20160410153507.GA1326@kroah.com>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
	<1460294020-2111-14-git-send-email-jsimmons@infradead.org>
	<63807394-FF62-4376-95FD-412309D47BF7@suse.com>
	<alpine.LFD.2.20.1604101500520.32661@casper.infradead.org>
	<20160410153507.GA1326@kroah.com>
Message-ID: <alpine.LFD.2.20.1604101647340.3112@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Jeff Mahoney <jeffm@suse.com>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> > > This patch was shown not to work. I just haven't removed it from opensuse yet.
> > 
> > Its been running in our production tree as well for some time. Guess that 
> > change is a noop. In any case we have been discussing redoing the lloop 
> > driver anyways. Just need to find the cycles.
> 
> Why do you need this driver?  I know Christoph has pointed out many
> times that it should just be dropped as it's not needed.

Please don't drop this driver just yet. The reason we kept it was for the DIO 
support that the loop back device lacked earlier. We need to do some 
testing to make sure the loop can completely replace this driver.

> And should I drop this patch from the series?

Yes since it is a noop. No other patches are dependent on it.
