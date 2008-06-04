From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 04 Jun 2008 10:24:19 +0900
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <007601c8c556$c904e660$5b0eb320$%tian@sun.com>
Message-ID: <C46C1DD3.5741%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Here is some more guidance for thinking about the Lustre quota design:

Adaptive qunits are great, but all I see is kind of a hack attempting to get
this right instead of a good design.  Here are some use cases you need to
address, and hopefully address with existing infrastructure.

(A) You need callbacks to change it, so that when it shrinks clients can
give up quota.

(B) mechanisms to recover the correct value if a client reconnects, or
master reboots.  

Starting from a hard coded default value is wrong.  If it's global, then
you'd need to store this in the configuration log so that it can be re-read
and managed when it changes, using the config log.

If it is a per user qunit then we may need an entirely new, similar
mechanism.  It probably is, and this is what worries me - it's a huge amount
of work to get this right.

Doing this is a LOT of work, and unless you do it right the implementation
will see a similar pattern of problems with customers as the previous one.

So I want to continue to challenge you by asking if there isn't a quota
solution that doesn't require adaptive behavior, at the expense of small
amounts of unmanaged space.


Peter




On 6/3/08 5:49 PM, "Landen tian" <Zhiyong.Tian@Sun.COM> wrote:

>> -----Original Message-----
>> From: lustre-devel-bounces at lists.lustre.org
>> [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Andreas Dilger
>> Sent: Tuesday, June 03, 2008 7:25 AM
>> To: Peter Braam
>> Cc: Bryon Neitzel; Johann Lombardi; Peter Bojanic; Jessica A. Johnson; Eric
>> Barton; Nikita Danilov; lustre-devel at lists.lustre.org
>> Subject: Re: [Lustre-devel] Moving forward on Quotas
>> 
>> On Jun 01, 2008  10:32 +0800, Peter J. Braam wrote:
>>> I am quite worried about the dynamic qunit patch.
>>> I am not convinced I want smaller qunits to stick around.
>>> 
>>> Please PROVE RIGOROUSLY that qunits are grow large quickly again,
>> otherwise
>>> they create too much server - server overhead.  The cost of 100MB of disk
>>> space is barely more than a cent now; what are we trying to address
> withtiny
>>> qunits?
>>> 
>>> Plan for 5000 OSS servers at the minimum and 1,000,000 clients, and up to
>>> 100TB/sec in I/O.  Calculate quota RPC traffic from that.  A server
> cannot
>>> handle more than 15,000 RPC's / sec.
>>> 
>>> No arguing, or opinions here, numbers please.  The original design I did
> 4
>>> years ago limited quota calls from one OSS to the master to one per
> second.
>>> Qunits were made adaptive without solid reasoning or design.
>> 
>> Just a note - it isn't only shrinking of qunits that is possible, but also
>> growth of qunits.  I think there was also work done to allow recall of
>> qunits from the servers, but I'm not sure if it was landed into CVS.
> 
> Yes, it has. In order to prevent ping-pong effect, if qunit is reduced,
> qunit _only_ could be
> Increased after the_latest_qunit_reduction + lqc_switch_seconds(default is
> 300 secs) . 
> At designing, we think accuracy is more urgent(otherwise, users will see
> earlier -EDQUOT),
> so decreasing can be done any time, but increasing has this limitation.
> 
> tianzy
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
