From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Wed, 28 May 2008 22:33:28 +0100
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <18493.51834.832400.315440@gargle.gargle.HOWL>
References: <C461688A.5460%peter.braam@sun.com>
	<1211984942.11750.29.camel@localhost>
	<18493.29199.765234.755534@gargle.gargle.HOWL>
	<1211987642.4740.10.camel@localhost>
	<18493.34513.370736.111492@gargle.gargle.HOWL>
	<1211994338.14599.24.camel@localhost>
	<18493.47971.504225.694251@gargle.gargle.HOWL>
	<1212008833.14599.84.camel@localhost>
	<18493.51834.832400.315440@gargle.gargle.HOWL>
Message-ID: <1212010408.14599.105.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Qui, 2008-05-29 at 01:11 +0400, Nikita Danilov wrote:

> Hm.. seems I am confused. If ZFS stores quota table internally, how this
> table is available to the upper layers, to implement policy?


uint64_t dmu_get_space_usage(objset, opaque_id)?

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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080528/87c8d71f/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080528/87c8d71f/attachment.gif>
