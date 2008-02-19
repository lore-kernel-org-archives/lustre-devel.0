From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Tue, 19 Feb 2008 15:18:10 +0000
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <op.t6r08rkfatmt0c@garden>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
	<47BABB01.8060402@sun.com> <47BAC53A.2030106@sun.com>
	<op.t6r08rkfatmt0c@garden>
Message-ID: <1203434290.10570.0.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Ter, 2008-02-19 at 17:59 +0300, Mikhail Pershin wrote: 

> Guys, don't forget about DMU as well.


For the DMU, we haven't reached a consensus on a final design for EAs in
dnode with the ZFS team yet.
The ZFS team proposed having variably-sized system attributes (with
integer indexes) instead of having name-value attributes like ext3.

I guess this is another good point to discuss in today's ZFS team
meeting.

Thanks,
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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080219/1241151b/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080219/1241151b/attachment.gif>
