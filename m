From: Landen tian <Zhiyong.Tian@Sun.COM>
Date: Wed, 04 Jun 2008 15:05:58 +0800
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <C46C1DD3.5741%peter.braam@sun.com>
References: <007601c8c556$c904e660$5b0eb320$%tian@sun.com>
	<C46C1DD3.5741%peter.braam@sun.com>
Message-ID: <000001c8c611$7252ecc0$56f8c640$%tian@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>-----Original Message-----
From: lustre-devel-bounces@lists.lustre.org
>[mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Peter Braam
>Sent: Wednesday, June 04, 2008 9:24 AM
>To: Landen tian; 'Andreas Dilger'
>Cc: 'Bryon Neitzel'; 'Johann Lombardi'; 'Peter Bojanic'; 'Jessica A.
Johnson'; 'Eric
>Barton'; 'Nikita Danilov'; lustre-devel at lists.lustre.org
>Subject: Re: [Lustre-devel] Moving forward on Quotas
>
>Here is some more guidance for thinking about the Lustre quota design:
>
>Adaptive qunits are great, but all I see is kind of a hack attempting to
get
>this right instead of a good design.  Here are some use cases you need to
>address, and hopefully address with existing infrastructure.
>
>(A) You need callbacks to change it, so that when it shrinks clients can
>give up quota.

All remained quota on quota slaves(osts etc) must be kept between [0.5qunit,
1.5qunit].
If quota slaves get a shrunken qunit, it will check if left quota on itself
satisfies
this limitation. If not, it will release some quota.

As we can't predict users will use which ost, we will give a qunit to every
ost at the
beginning so that they can use it when writes relative to quota comes later.
So if we
want to shrink qunit, we need shrink all osts. 

>
>(B) mechanisms to recover the correct value if a client reconnects, or
>master reboots.
>
>Starting from a hard coded default value is wrong.  If it's global, then
>you'd need to store this in the configuration log so that it can be re-read
>and managed when it changes, using the config log.

When every quota req arrives, quota master(mds) will recalculate the qunit
to decide
if it would enlarge or shrink a qunit to a proper value(this computing is
simple, the cost is low).
After rebooting, mds will know the proper qunit after the first quota req is
finished; 
As current qunit will be contained in the reply of quota req, osts will know
current qunit
after a quota req is finished. In this way, no matter a client reconnects or
master reboot,
the proper quota info is spread over all cluster gradually. Now, the qunit
info only is recoreded in 
memory, not disk. After rebooting or reconnecting, it will be recovered in
running time.

Certainly, we can record it in the config log. It would be easier to
reconnect and reboot, 
but there may be hundreds or thousands of quota usrs/grps In the system, and
we may flush this info to log from time to time because this info is
dynamic. We have 
gains and losses, please advice if it is worthy.

>
>If it is a per user qunit then we may need an entirely new, similar
>mechanism.  It probably is, and this is what worries me - it's a huge
amount
>of work to get this right.

Yeah, adaptive qunit is per user and per group.

>Doing this is a LOT of work, and unless you do it right the implementation
>will see a similar pattern of problems with customers as the previous one.
>
>So I want to continue to challenge you by asking if there isn't a quota
>solution that doesn't require adaptive behavior, at the expense of small
>amounts of unmanaged space.

I guess we need borrow mechanism from ldlm to achieve it as Johann said
before.

tianzy
