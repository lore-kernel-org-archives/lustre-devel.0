From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 17 Apr 2008 10:56:48 -0700
Subject: [Lustre-devel] Failover & Force export for the DMU
In-Reply-To: <1208448631.6677.82.camel@localhost>
Message-ID: <C42CDD70.3857%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I forgot one other comment/question: shutdown of Lustre servers was
traditionally sometimes very slow because of timeouts ? however with the
Sandia ?kill the export features? is this still true?

- peter -


On 4/17/08 9:10 AM, "Ricardo M. Correia" <Ricardo.M.Correia@Sun.COM> wrote:

> Hi Peter,
> 
> Please see my comments.
> 
> On Qua, 2008-04-16 at 17:18 -0700, Peter Braam wrote:
>>  I think that is fine ? again, the key issue is not to kill the server while
>> it gets these errors.  It may well be that the server needs a special ?I?m
>> recovering be gentle with errors? mode to avoid reasonable panics.
> 
> I would say any error returned by the filesystem even in normal operation
> should be handled gently :)
> 
>>  Please explain why we want to export such a pool and on which node we want
>> to export it, in fact what is ?export? (it should be similar to unmount)?  If
>> things are failing, then, on the node that is failing, we don?t need this
>> pool anymore, we need to shut things down, in most cases for a reboot.  We
>> need the pool on the failover node.
> 
> The DMU has the notion of importing and exporting a pool, which is different
> from mounting/unmounting a filesystem inside the pool.
> 
> Basically, an import consists in scanning and reading the labels of all the
> devices of a pool to find out the pool configuration.
> After this process, the pool transitions to the imported state, which means
> that the DMU knows about the pool (has the pool configuration cached) and the
> user can perform any operation he desires on the pool.
> 
> Usually after an import ZFS also mounts the filesystems inside the pool
> automatically, but this is not relevant here.
> 
> In ZFS, an export consists of unmounting any filesystem belonging to the pool,
> flushing dirty data, marking the pool as exported on-disk and then removing
> the pool configuration from the cache.
> In Lustre/ZFS, strictly speaking there are no filesystems mounted so we don't
> do that, but of course the export would fail if Lustre has an open objset, so
> we need to close them first.
> After this, the user can only operate/manipulate the pool if he re-imports it.
> 
> So basically, what we need to do when things are failing (in the node that is
> failing) is to close the filesystems and export the pool. The big problem is
> that the DMU cannot export a pool if the devices are experiencing fatal write
> failures, which is why we need a force-export mechanism.
> 
> After that, we need to import the pool on the failover node and mount all the
> MDTs/OSTs that were stored there, do recovery, etc (I'm sure you understand
> this process much better than I do :)
> 
> 
>>  In fact there is a very useful distinction to make.  There are two failover
>> scenarios: 
>> 1. fail over to move services away from failures on the OSS.  In this case a
>> reboot/panic is not really harmful.
> 
> That's why when I heard about the need for this feature, I immediately
> proposed doing a panic, which wouldn't have any consequences assuming Lustre
> recovery does its job. But it's not useful in a "multiple pools in the same
> server" scenario.
> 
>>  
>> 1. fail over from a fully functioning OSS/DMU to redistribute services.  In
>> this case we need a control mechanism to turn the device read-only and clean
>> up the DMU. 
> 
> Why do we need to turn the device read-only in this case? Why can't we do a
> clean unmount/export if the devices are fully functioning?
> Andreas has told me before that with ldiskfs, doing a clean unmount could take
> a lot of time if there's a lot of dirty data, but I don't believe this will be
> true with the DMU.
> Even if such a problem were to arise, in the DMU it's trivial to limit the
> transaction group size and therefore limit the time it takes to sync a txg.
> 
>>  Unfortunately we cannot consider mandating that there is only one file
>> system per OSS because then we need an idle node to act as the failover node.
>> We must handle the problem of shutting ?one of more? down, but only in the
>> clean case (2). 
> 
> In the clean case, we don't need force-export.
> 
> Force-export is only really needed if all of the following conditions are
> true:
> 
> 1) We have more than 1 filesystem (MDT/OST) running in the same userspace
> process (note how I didn't say "same server". Also note that for Lustre 2.0,
> we will have a limitation of 1 userspace process per server).
> 
> 2) The MDTs/OSTs are stored in more than 1 ZFS pool (note how I didn't say
> "more than 1 device". A single ZFS pool can use multiple disk devices.).
> 
> 3) One or more, but not all of the ZFS pools are suffering from fatal IO
> failures.
> 
> 4) We only want to failover the MDTs/OSTs stored on the pools that are
> suffering IO failures, but we still want to keep the remaining MDTs/OSTs
> working in the same server.
> 
> If there is a requirement of supporting a scenario where all of these
> conditions are true, then we need force-export. From my latest discussion with
> Andreas about this, we do need that.
> If not all of the conditions are true, we could either do a clean export or do
> a panic, depending on the situation.
> 
> At least, that is my understanding :)
> 
> Thanks,
> Ricardo
> 
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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080417/c936ff61/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: image.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080417/c936ff61/attachment.gif>
