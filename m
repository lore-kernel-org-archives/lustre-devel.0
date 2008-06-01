From: Peter Braam <Peter.Braam@Sun.COM>
Date: Sun, 01 Jun 2008 10:32:46 +0800
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <20080528080613.GN3582@lore>
Message-ID: <C4682B4E.5615%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I am quite worried about the dynamic qunit patch.
I am not convinced I want smaller qunits to stick around.

Please PROVE RIGOROUSLY that qunits are grow large quickly again, otherwise
they create too much server - server overhead.  The cost of 100MB of disk
space is barely more than a cent now; what are we trying to address withtiny
qunits?

Plan for 5000 OSS servers at the minimum and 1,000,000 clients, and up to
100TB/sec in I/O.  Calculate quota RPC traffic from that.  A server cannot
handle more than 15,000 RPC's / sec.

No arguing, or opinions here, numbers please.  The original design I did 4
years ago limited quota calls from one OSS to the master to one per second.
Qunits were made adaptive without solid reasoning or design.

Peter


On 5/28/08 4:06 PM, "Johann Lombardi" <johann@sun.com> wrote:

> Hello Peter,
> 
> On Tue, May 27, 2008 at 07:28:10AM +0800, Peter Braam wrote:
>>>> When a slave runs out of its local quota, it sends an acquire request to
>>>> the
>>>> quota master. As I said earlier, the quota master is the only one having a
>>>> global overview of what has been granted to slaves. If the master can
>>>> satisfy
>>>> the request, it grants a qunit (can be a number of blocks or inodes) to the
>>>> slave. The problem is that an OST can return "quota exceeded" (=EDQUOT)
>>>> whereas
>>>> another OST is still having quotas. There is currently no callback to claim
>>>> back the quota space that has been granted to a slave.
>> 
>> Hmm - the slave should release quota.
> 
> I don't think that the slave can make such a decision by itself since it does
> not know that we are getting closer to the global quota limit. Only the master
> is aware of this.
> Actually, the scenario I described above can no longer happen - with recent
> lustre versions at least - thanks to the dynamic qunit patch because the
> master broadcasts to all the slaves the new qunit size when it is shrunk.
> 
> Cheers,
> Johann
