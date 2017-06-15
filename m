From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 15 Jun 2017 18:56:33 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: headers: potential UAPI
 headers
In-Reply-To: <alpine.LFD.2.20.1706140149160.20798@casper.infradead.org>
References: <1482167207-22800-1-git-send-email-jsimmons@infradead.org>
	<20170103141248.GA8695@kroah.com>
	<alpine.LFD.2.20.1701162126170.27875@casper.infradead.org>
	<20170117074140.GA19328@kroah.com>
	<alpine.LFD.2.20.1701202331420.11070@casper.infradead.org>
	<20170121092459.GA29138@kroah.com>
	<32AAAA94-0C88-40F5-8FAD-37F35A401AC3@intel.com>
	<20170613042531.GB13308@kroah.com>
	<alpine.LFD.2.20.1706140149160.20798@casper.infradead.org>
Message-ID: <20170615165633.GA4478@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Jun 15, 2017 at 04:48:20PM +0100, James Simmons wrote:
> So this is coming from trying to understand the "merge them together" 
> part. Some people reading this it implies all the headers would be 
> eventually merged into one big header and placed into include/uapi/linux. 

Sounds like a good plan, why wouldn't you want something nice and simple
like that?  :)

> We are getting to the point where some sites are migrating from the out
> of tree branch to this client. This also means they will be moving 
> external open source userland applications shortly. If we expose UAPI 
> headers that are completely different that it breaks their tools users
> will dump this client and go back to the out source tree. We really like
> to avoid that.

Note, as the code is still in staging, files will get renamed and moved
around, you know that, nothing we can do here at the moment.

I have yet to see any patches yet, so I don't know why people are
complaining...

thanks,

greg k-h
