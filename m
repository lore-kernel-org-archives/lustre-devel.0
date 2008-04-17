From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 16 Apr 2008 17:18:51 -0700
Subject: [Lustre-devel] Failover & Force export for the DMU
In-Reply-To: <1208364036.15849.133.camel@localhost>
Message-ID: <C42BE57B.37FA%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 4/16/08 9:40 AM, "Ricardo M. Correia" <Ricardo.M.Correia@Sun.COM> wrote:
... SNIP

> I agree, but I'm not so sure we should still continue to send read requests to
> the storage devices when we are failing over. One of the reasons the failover
> could be happening is due to a failure somewhere in the server -> storage
> path, and if this is happening we may experience delays of 30 or 60 seconds
> for the IOs to timeout, especially if we're doing synchronous I/O in the ZIO
> threads like we are doing now.
> 
> So I think returning EIO for reads on the backend storage might be more
> appropriate during a failover.
> 
I think that is fine ? again, the key issue is not to kill the server while
it gets these errors.  It may well be that the server needs a special ?I?m
recovering be gentle with errors? mode to avoid reasonable panics.
> 
>>  Ricardo ? for the DMU all you need to do is make sure you can quickly turn a
>> device read only below the DMU and the DMU can handle that (its like doing
>> ?mount ?o remount, ro?).
> 
> Well, it's a bit more complicated than that..
> If there is a fatal failure to write to the backend devices, the error will be
> returned to the ZIO pipeline and the DMU's behavior will again depend on the
> "failmode" property of the pool, which can have 3 different values:
> 
> - wait mode: I/O is blocked until the administrator corrects the problem
> manually. This is useful for regular ZFS pools, because the administrator has
> a chance to replace the device that is experiencing IO failures and therefore
> prevent any data loss.
> 
> - continue mode: (quoting) "Returns EIO to any new write I/O requests" (in the
> transaction phase) ".. but allows reads to any of the remaining healthy
> devices. Any write requests that have yet to be committed to disk would be
> blocked."
> 
> - panic mode: in userspace, we do an abort(). This would be a good solution
> for Lustre if we didn't have multiple ZFS pools in the same userspace server,
> but it's not useful at all in that case.
> 
Well yes, the problem is that controlled failovers are required, for example
when you fail back.
> 
> 
> The big problem here is that neither the "wait" mode nor the "continue" mode
> allow a pool with dirty data to be exported if the backend devices are
> returning errors in the pwrite() calls (be it EROFS, EIO, or any other), due
> to ZFS's insistence on preserving data integrity (which I think is very well
> designed).
> 
Please explain why we want to export such a pool and on which node we want
to export it, in fact what is ?export? (it should be similar to unmount)?
If things are failing, then, on the node that is failing, we don?t need this
pool anymore, we need to shut things down, in most cases for a reboot.  We
need the pool on the failover node.

In fact there is a very useful distinction to make.  There are two failover
scenarios:
1. fail over to move services away from failures on the OSS.  In this case a
reboot/panic is not really harmful.
2. fail over from a fully functioning OSS/DMU to redistribute services.  In
this case we need a control mechanism to turn the device read-only and clean
up the DMU.

Unfortunately we cannot consider mandating that there is only one file
system per OSS because then we need an idle node to act as the failover
node.  We must handle the problem of shutting ?one of more? down, but only
in the clean case (2).
> 
> I have thought a lot about this, and my conclusion is that when
> force-exporting a pool we should make the DMU discard all writes to the
> backend storage, make reads (even "must succeed" reads) return EIO, and then
> go through the normal DMU export process. I believe this is the only sane way
> of successfully getting rid of dirty data in the DMU without any loss of
> transactional integrity or weird failures, but it will also require changing
> the DMU to gracefully handle failures in "must succeed" reads, which will not
> be easy..
> 
Sun already has products (a CIFS server) that can failover on ZFS.  It might
be interesting to ask them if they can handle failing over one ZFS file
system while keeping others, because this is essentially the same problem as
we have from a DMU perspective.

Peter
> 
> The consequence for Lustre is that the OSS/MDS servers *must* be able to
> handle errors gracefully because the DMU could return a lot of EIOs during
> failover.
> 
> Cheers,
> Ricardo
> --
> Ricardo Manuel Correia
> Lustre Engineering
> 
> Sun Microsystems, Inc.
> Portugal
> Phone +351.214134023 / x58723
> Mobile +351.912590825
> Email Ricardo.M.Correia at Sun.COM
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080416/7096dade/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: image.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080416/7096dade/attachment.gif>
