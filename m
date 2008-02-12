From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Tue, 12 Feb 2008 00:25:14 +0000
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47B0CCFC.80102@sun.com>
References: <47AB2FA7.10205@Sun.COM> <47AC7B75.30603@cea.fr>
	<20080211181850.GA6552@webber.adilger.int>
	<1202764303.6391.42.camel@localhost>
	<20080211213956.GK3029@webber.adilger.int>
	<1202767637.6391.60.camel@localhost> <47B0CCFC.80102@sun.com>
Message-ID: <1202775914.6391.77.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Seg, 2008-02-11 at 14:32 -0800, Nathaniel Rutman wrote:

> I'm missing the point of this discussion.  Clearly we shouldn't/can't 
> use ctime/mtime for anything internal to Lustre; that is what object 
> versions are all about.  Why are we talking about adding new fields or 
> anything else?



If by object versions you are referring to the version field in the
ldiskfs inodes that Andreas mentioned, then we need to add a similar
field/attribute in ZFS.

It seems that Andreas has already filed bug 14865 for this.

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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080212/70ae527c/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080212/70ae527c/attachment.gif>
