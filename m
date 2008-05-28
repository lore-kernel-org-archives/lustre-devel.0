From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Thu, 29 May 2008 01:11:22 +0400
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <1212008833.14599.84.camel@localhost>
References: <C461688A.5460%peter.braam@sun.com>
	<1211984942.11750.29.camel@localhost>
	<18493.29199.765234.755534@gargle.gargle.HOWL>
	<1211987642.4740.10.camel@localhost>
	<18493.34513.370736.111492@gargle.gargle.HOWL>
	<1211994338.14599.24.camel@localhost>
	<18493.47971.504225.694251@gargle.gargle.HOWL>
	<1212008833.14599.84.camel@localhost>
Message-ID: <18493.51834.832400.315440@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ricardo M. Correia writes:

[...]

 > The plan we discussed with the ZFS team was to make the DMU do space
 > accounting internally by opaque ids, so the quota policy/enforcement
 > would still be left to the upper layers to implement.

Hm.. seems I am confused. If ZFS stores quota table internally, how this
table is available to the upper layers, to implement policy?

Nikita.
