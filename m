From: James Simmons <jsimmons@infradead.org>
Date: Sun, 29 Jan 2017 23:56:38 +0000 (GMT)
Subject: [lustre-devel] [PATCH 0/8] staging: lustre: lnet: change wire
 protocol typedefs to proper structure
In-Reply-To: <1485205276.12563.30.camel@perches.com>
References: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
	<1485205276.12563.30.camel@perches.com>
Message-ID: <alpine.LFD.2.20.1701292354160.7496@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <uja.ornl@yahoo.com>


> On Sat, 2017-01-21 at 19:40 -0500, James Simmons wrote:
> > The upstream kernel requires proper structures so
> > convert nearly all the LNet wire protocols typedefs in
> > the LNet core.
> 
> Thanks.
> 
> Perhaps s/\bWIRE_ATTR\b/__packed/g one day too

I liked to keep that one. The point of WIRE_ATTR isn't to be
some abstraction but to label that struct as something that
goes over the wire. This lets people know that it would break
something if you change that structure. Looks like I need to
send a patch that adds a comment explaning the meaning of
WIRE_ATTR.
