From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 30 Jan 2017 07:40:19 +0100
Subject: [lustre-devel] [PATCH 0/8] staging: lustre: lnet: change wire
 protocol typedefs to proper structure
In-Reply-To: <alpine.LFD.2.20.1701292354160.7496@casper.infradead.org>
References: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
	<1485205276.12563.30.camel@perches.com>
	<alpine.LFD.2.20.1701292354160.7496@casper.infradead.org>
Message-ID: <20170130064018.GA4108@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Joe Perches <joe@perches.com>, devel@driverdev.osuosl.org, James Simmons <uja.ornl@yahoo.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sun, Jan 29, 2017 at 11:56:38PM +0000, James Simmons wrote:
> 
> > On Sat, 2017-01-21 at 19:40 -0500, James Simmons wrote:
> > > The upstream kernel requires proper structures so
> > > convert nearly all the LNet wire protocols typedefs in
> > > the LNet core.
> > 
> > Thanks.
> > 
> > Perhaps s/\bWIRE_ATTR\b/__packed/g one day too
> 
> I liked to keep that one.

Sorry, but no.

> The point of WIRE_ATTR isn't to be some abstraction but to label that
> struct as something that goes over the wire. This lets people know
> that it would break something if you change that structure. Looks like
> I need to send a patch that adds a comment explaning the meaning of
> WIRE_ATTR.

No, please remove it, it's not anything that any other kernel subsystem
uses.

It's easy to know if you will break something, anything that crosses the
user/kernel boundry falls into that category, so if it is in a uapi .h
file, that's going to be the case.

thanks,

greg k-h
