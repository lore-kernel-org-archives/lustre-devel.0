From: Joe Perches <joe@perches.com>
Date: Fri, 01 Apr 2016 11:54:18 -0700
Subject: [lustre-devel] [RFC PATCH 0/3] staging: lustre: detypedef
In-Reply-To: <e80afb24bd424ab183bc7732ed556d3a@EXCHCS32.ornl.gov>
References: <cover.1459515208.git.joe@perches.com>
	<e80afb24bd424ab183bc7732ed556d3a@EXCHCS32.ornl.gov>
Message-ID: <1459536858.1744.30.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Simmons, James A." <simmonsja@ornl.gov>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On Fri, 2016-04-01 at 15:58 +0000, Simmons, James A. wrote:
> > When would be an appropriate time to submit patches similar to
> > below that individually remove various typedefs from lustre code?
> > 
> > These are pretty trivial to produce and verify so there's no
> > particular hurry to do them now but applying them will require
> > resync points for active and actually useful developers.

> Actually could you hold off for the LNet core and LND drivers these
> changes. I have plans to push a few more LNet patches soon. I have
> been just waiting for everyone to figure out how to deal with the?
> latest changes to the infinband layer first.

Sure. ?No worries.

> There are a few typedefs like lnet_nid_t I like to keep or if it has to
> be changed turn it into a struct then. Things like lnet_nid_t act like
> a cookie handle.

Fine by me.
