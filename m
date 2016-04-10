From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 10 Apr 2016 08:35:07 -0700
Subject: [lustre-devel] [PATCH 13/17] staging: lustre: lloop: Fix build
	failure on ppc64
In-Reply-To: <alpine.LFD.2.20.1604101500520.32661@casper.infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
	<1460294020-2111-14-git-send-email-jsimmons@infradead.org>
	<63807394-FF62-4376-95FD-412309D47BF7@suse.com>
	<alpine.LFD.2.20.1604101500520.32661@casper.infradead.org>
Message-ID: <20160410153507.GA1326@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Jeff Mahoney <jeffm@suse.com>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sun, Apr 10, 2016 at 03:04:51PM +0100, James Simmons wrote:
> 
> > This patch was shown not to work. I just haven't removed it from opensuse yet.
> 
> Its been running in our production tree as well for some time. Guess that 
> change is a noop. In any case we have been discussing redoing the lloop 
> driver anyways. Just need to find the cycles.

Why do you need this driver?  I know Christoph has pointed out many
times that it should just be dropped as it's not needed.

And should I drop this patch from the series?

thanks,

greg k-h
