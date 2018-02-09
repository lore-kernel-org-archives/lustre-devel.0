From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 8 Feb 2018 21:01:35 -0500
Subject: [lustre-devel] [PATCH 41/80] staging: lustre: lmv: separate
 master object with master stripe
In-Reply-To: <87r2pvkkl5.fsf@notabene.neil.brown.name>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
 <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
 <87r2pvkkl5.fsf@notabene.neil.brown.name>
Message-ID: <09CE6CEC-52BC-4B29-B609-40DE68A64A33@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, wang di <di.wang@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Feb 8, 2018, at 8:39 PM, NeilBrown <neilb@suse.com> wrote:
> 
> On Tue, Aug 16 2016, James Simmons wrote:

my that?s an old patch

> 
>> 
>> +static inline bool
>> +lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
>> +{
>> +	int idx;
>> +
>> +	if (lsm1->lsm_md_magic != lsm2->lsm_md_magic ||
>> +	    lsm1->lsm_md_stripe_count != lsm2->lsm_md_stripe_count ||
>> +	    lsm1->lsm_md_master_mdt_index != lsm2->lsm_md_master_mdt_index ||
>> +	    lsm1->lsm_md_hash_type != lsm2->lsm_md_hash_type ||
>> +	    lsm1->lsm_md_layout_version != lsm2->lsm_md_layout_version ||
>> +	    !strcmp(lsm1->lsm_md_pool_name, lsm2->lsm_md_pool_name))
>> +		return false;
> 
> Hi James and all,
> This patch (8f18c8a48b736c2f in linux) is different from the
> corresponding patch in lustre-release (60e07b972114df).
> 
> In that patch, the last clause in the 'if' condition is
> 
> +           strcmp(lsm1->lsm_md_pool_name,
> +                     lsm2->lsm_md_pool_name) != 0)
> 
> Whoever converted it to "!strcmp()" inverted the condition.  This is a
> perfect example of why I absolutely *loathe* the "!strcmp()" construct!!
> 
> This causes many tests in the 'sanity' test suite to return
> -ENOMEM (that had me puzzled for a while!!).

huh? I am not seeing anything of the sort and I was running sanity
all the time until a recent pause (but going to resume).

> This seems to suggest that no-one has been testing the mainline linux
> lustre.
> It also seems to suggest that there is a good chance that there
> are other bugs that have crept in while no-one has really been caring.
> Given that the sanity test suite doesn't complete for me, but just
> hangs (in test_27z I think), that seems particularly likely.

Works for me, here?s a run from earlier today on 4.15.0:
== sanity test 27z: check SEQ/OID on the MDT and OST filesystems ===================================== 16:43:58 (1518126238)
1+0 records in
1+0 records out
1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.0169548 s, 61.8 MB/s
2+0 records in
2+0 records out
2097152 bytes (2.1 MB, 2.0 MiB) copied, 0.02782 s, 75.4 MB/s
check file /mnt/lustre/d27z.sanity/f27z.sanity-1
FID seq 0x200000401, oid 0x4640 ver 0x0
LOV seq 0x200000401, oid 0x4640, count: 1
want: stripe:0 ost:0 oid:314/0x13a seq:0
Stopping /mnt/lustre-ost1 (opts:) on centos6-17
pdsh at fedora1: centos6-17: ssh exited with exit code 1
pdsh at fedora1: centos6-17: ssh exited with exit code 1
pdsh at fedora1: centos6-17: ssh exited with exit code 1
Starting ost1:   -o loop /tmp/lustre-ost1 /mnt/lustre-ost1
Failed to initialize ZFS library: 256
h2tcp: deprecated, use h2nettype instead
centos6-17.localnet: executing set_default_debug vfstrace rpctrace dlmtrace neterror ha config ioctl super all -lnet -lnd -pinger 16
pdsh at fedora1: centos6-17: ssh exited with exit code 1
pdsh at fedora1: centos6-17: ssh exited with exit code 1
Started lustre-OST0000
/mnt/lustre-ost1/O/0/d26/314: parent=[0x200000401:0x4640:0x0] stripe=0 stripe_size=0 stripe_count=0
check file /mnt/lustre/d27z.sanity/f27z.sanity-2
FID seq 0x200000401, oid 0x4642 ver 0x0
LOV seq 0x200000401, oid 0x4642, count: 2
want: stripe:0 ost:1 oid:1187/0x4a3 seq:0
Stopping /mnt/lustre-ost2 (opts:) on centos6-17
pdsh at fedora1: centos6-17: ssh exited with exit code 1
pdsh at fedora1: centos6-17: ssh exited with exit code 1
pdsh at fedora1: centos6-17: ssh exited with exit code 1
Starting ost2:   -o loop /tmp/lustre-ost2 /mnt/lustre-ost2
Failed to initialize ZFS library: 256
h2tcp: deprecated, use h2nettype instead
centos6-17.localnet: executing set_default_debug vfstrace rpctrace dlmtrace neterror ha config ioctl super all -lnet -lnd -pinger 16
pdsh at fedora1: centos6-17: ssh exited with exit code 1
pdsh at fedora1: centos6-17: ssh exited with exit code 1
Started lustre-OST0001
/mnt/lustre-ost2/O/0/d3/1187: parent=[0x200000401:0x4642:0x0] stripe=0 stripe_size=0 stripe_count=0
want: stripe:1 ost:0 oid:315/0x13b seq:0
got: objid=0 seq=0 parent=[0x200000401:0x4642:0x0] stripe=1
Resetting fail_loc on all nodes...done.
16:44:32 (1518126272) waiting for centos6-16 network 5 secs ...
16:44:32 (1518126272) network interface is UP
16:44:33 (1518126273) waiting for centos6-17 network 5 secs ...
16:44:33 (1518126273) network interface is UP


> So my real question - to anyone interested in lustre for mainline linux
> - is: can we actually trust this code at all?

Absolutely. Seems that you just stumbled upon a corner case that was not
being hit by people that do the testing, so you have something unique about
your setup, I guess.

> I'm seriously tempted to suggest that we just
>  rm -r drivers/staging/lustre
> 
> drivers/staging is great for letting the community work on code that has
> been "thrown over the wall" and is not openly developed elsewhere, but
> that is not the case for lustre.  lustre has (or seems to have) an open
> development process.  Having on-going development happen both there and
> in drivers/staging seems a waste of resources.

It is a bit of a waste of resources, but there are some other things here.
E.g. we cannot have any APIs with no users in the kernel.
Also some people like to have in-kernel modules coming with their distros
(there were some users that used staging client on ubuntu as their
setup).

Instead the plan was to clean up the staging client into acceptable state,
move it out of staging, bring in all the missing features and then
drop the client (more or less) from the lustre-release. 

> Might it make sense to instead start cleaning up the code in
> lustre-release so as to make it meet the upstream kernel standards.
> Then when the time is right, the kernel code can be moved *out* of
> lustre-release and *in* to linux.  Then development can continue in
> Linux (just like it does with other Linux filesystems).

While we can be cleaning lustre in lustre-release, there are some things
we cannot do as easily, e.g. decoupling Lustre client from the server.
Also it would not attract any reviews from all the janitor or
(more importantly) Al Viro and other people with a sharp eyes.

> An added bonus of this is that there is an obvious path to getting
> server support in mainline Linux.  The current situation of client-only
> support seems weird given how interdependent the two are.

Given the pushback Lustre client was given I have no hope Lustre server
will get into mainline in my lifetime.

> What do others think?  Is there any chance that the current lustre in
> Linux will ever be more than a poor second-cousin to the external
> lustre-release.  If there isn't, should we just discard it now and move
> on?


I think many useful cleanups and fixes came from the staging tree at
the very least.
The biggest problem with it all is that we are in staging tree so
we cannot bring it to parity much. And we are in staging tree because
there?s a whole bunch of ?cleanups? requested that take a lot of effort
(in both implementing them and then in finding other ways of achieving
things that were done in old ways before).
I understand that beggars cannot be choosers and while there are people
that are grandfathered with their atrocities in current kernel tree,
we must adhere to the shining standards first before having our chance,
but the standards are not easy to adhere to in an established sizeable
codebase.

Realistically speaking I suspect if we drop Lustre from staging,
it?s unlikely there would remain any steam behind the cleanup efforts
at all.

Bye,
    Oleg
