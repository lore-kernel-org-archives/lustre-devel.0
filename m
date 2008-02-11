From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Mon, 11 Feb 2008 22:07:17 +0000
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <20080211213956.GK3029@webber.adilger.int>
References: <47AB2FA7.10205@Sun.COM> <47AC7B75.30603@cea.fr>
	<20080211181850.GA6552@webber.adilger.int>
	<1202764303.6391.42.camel@localhost>
	<20080211213956.GK3029@webber.adilger.int>
Message-ID: <1202767637.6391.60.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Seg, 2008-02-11 at 14:39 -0700, Andreas Dilger wrote:

> The problem with ctime (on Linux as well) is that it is possible for the
> system clock to go backward, whether due to ntp, or because the hardware
> clock is incorrect/reset, so it cannot be depended upon to be monotonically
> increasing for the life of the lustre filesystem.


Ok. In that case, we could either add a new 64-bit version field to the
dnode (or znode) similar to the one in ldiskfs, or we could look at the
birth time (txg nr) of all the block pointers in the dnode.
Using txg numbers might not be very useful if an object is migrated from
one storage device to another, but I have not read the HSM HLD so I'm
not sure if this is a problem or not.

Cheers,
Ricardo
--

Ricardo Manuel Correia
Lustre Engineering

Sun Microsystems, Inc.
Portugal
Phone +351.214134023 / x58723
Mobile +351.912590825
Email Ricardo.M.Correia at Sun.COM
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080211/4de0ee30/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080211/4de0ee30/attachment.gif>
