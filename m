From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Wed, 23 Apr 2008 22:15:35 +0100
Subject: [Lustre-devel] Lustre and zfs on solaris
In-Reply-To: <EF69F797-BC90-4CED-BB82-DB0300B4D96B@Sun.COM>
References: <6C2A6456-4B2C-412C-A6C2-7B2066D2C438@sun.com>
	<EF69F797-BC90-4CED-BB82-DB0300B4D96B@Sun.COM>
Message-ID: <1208985335.7065.65.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi James,
?

> > > On Apr 18, 2008, at 6:42 PM, James Hartley wrote: 
> > > 
> > > > I have a REAL need to get involved with this.  Do you have a
> > > > beta test
> > > > program or can I join the development of Lustre and ZFS on
> > > > solaris.  I
> > > > am willing to do what is necessary to come up to speed and
> > > > either work
> > > > directly or test this product.

(snip)

> > > > If there is a current beta in the works please inform me how I
> > > > can get
> > > > a copy and help.


I don't know what is your background with Lustre, but here are a few
links to get you started:

* Lustre operations manual:
http://manual.lustre.org/index.php?title=Main_Page

?* Lustre build instructions:
http://wiki.lustre.org/index.php?title=BuildLustre

* Access instructions for the CVS repository:
http://wiki.lustre.org/index.php?title=Open_CVS

* How to build/setup the userspace OSS (this is what you want the most):
http://wiki.lustre.org/index.php?title=Lustre_OSS/MDS_with_ZFS_DMU

Note that currently only the userspace OSS can be used in Solaris (and
with ZFS).
Also note that when using the uOSS, you have to use an MDS compiled from
the HEAD branch.

Please let me know if you have any questions.

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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080423/61737c35/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080423/61737c35/attachment.gif>
