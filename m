From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Thu, 29 May 2008 12:39:53 +0400
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <1212010408.14599.105.camel@localhost>
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
Message-ID: <18494.27609.986096.752687@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ricardo M. Correia writes:
 > On Qui, 2008-05-29 at 01:11 +0400, Nikita Danilov wrote:
 > 
 > > Hm.. seems I am confused. If ZFS stores quota table internally, how this
 > > table is available to the upper layers, to implement policy?
 > 
 > 
 > uint64_t dmu_get_space_usage(objset, opaque_id)?

It is not immediately clear how chown and chgrp can be implemented on
top of this. Plus an interface to iterate over this table is most likely
required for quota tools.

To return to the question why using call-backs notifying about object
space allocation changes is preferable to maintaining space allocation
per-id in file system: opaqueid's have to be visible not only in the dmu
interface, but also in osd interface, because quota policy is
implemented above osd. But 

    - osd knows nothing about users and groups (it uses capability-based
      access control), and its interface has to be expanded to pass
      through identifiers that it doesn't understand and doesn't
      use. This looks wrong. osd operates on objects, identified by
      fids, and it would be much more natural to do space accounting on
      the object granularity.

    - osd interface is identical on all platforms, so, in effect, zfs
      space accounting interface is enforced on ldiskfs (and on all
      possible future back-ends).

 > Ricardo Manuel Correia
 > Lustre Engineering

Nikita.
