From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Sat, 31 May 2008 16:49:19 +0100
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <1212247880.21348.73.camel@localhost>
References: <C461688A.5460%peter.braam@sun.com>
	<1211984942.11750.29.camel@localhost>
	<18493.29199.765234.755534@gargle.gargle.HOWL>
	<1211987642.4740.10.camel@localhost>
	<18493.34513.370736.111492@gargle.gargle.HOWL>
	<1211994338.14599.24.camel@localhost>
	<18493.47971.504225.694251@gargle.gargle.HOWL>
	<1212008833.14599.84.camel@localhost>
	<18493.51834.832400.315440@gargle.gargle.HOWL>
	<1212010408.14599.105.camel@localhost>
	<18494.27609.986096.752687@gargle.gargle.HOWL>
	<18496.11672.844774.815457@gargle.gargle.HOWL>
	<1212247880.21348.73.camel@localhost>
Message-ID: <1212248959.21348.77.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On S?b, 2008-05-31 at 16:31 +0100, Ricardo M. Correia wrote:

> This may shock you, but depending on the pool configuration,
> filesystem properties and object block size, writing 1 MB of file data
> can take anywhere from exactly 0 bytes to 9.25 MB of allocated space
> (!!).


Let me correct that: in the very worst case scenario, writing 1 MB of
file data can actually consume (a bit more than) 11.25 MB of allocated
space..

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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080531/4031336e/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080531/4031336e/attachment.gif>
