From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Tue, 19 Feb 2008 15:23:11 +0000
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <1203433891.3999.8.camel@localhost>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
	<47BABB01.8060402@sun.com> <47BAC53A.2030106@sun.com>
	<op.t6r08rkfatmt0c@garden> <1203433891.3999.8.camel@localhost>
Message-ID: <1203434591.10570.3.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Ter, 2008-02-19 at 20:41 +0530, Kalpak Shah wrote:

> The epoch will need to be stored in an external block or
> FatZap (depending on implementation of in-dnode EAs) only in-case the
> file is striped across more than 10-15 OSTs.


That may not be true.
For example, with Matthew's proposed design, we could put the epoch as a
system attribute with "higher priority" (lower index) than LOV data,
which means it would always fit in the dnode even if we have lots of
LOVs.

Regards,
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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080219/81be0367/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080219/81be0367/attachment.gif>
