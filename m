From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 17 Apr 2008 10:53:17 -0700
Subject: [Lustre-devel] Failover & Force export for the DMU
In-Reply-To: <1208448631.6677.82.camel@localhost>
Message-ID: <C42CDC9D.3855%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 4/17/08 9:10 AM, "Ricardo M. Correia" <Ricardo.M.Correia@Sun.COM> wrote:
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
I don?t think this is valid reasoning.  If one pool is hosed, it is just as
well to reboot the node.  At best what you are proposing is a ?nice to have
refinement? but not necessary for proper management of Lustre clusters.

Following my proposal seems to eliminate the requirement for very
complicated work.
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
Yes.  But this is not a requirement, because for example 4) is not necessary
for customer happiness.
> 
> If there is a requirement of supporting a scenario where all of these
> conditions are true, then we need force-export. From my latest discussion with
> Andreas about this, we do need that.
> 
No we do not.  Andreas, please get in touch with me.  I think this is a
?nice to have? but not important enough.

-Peter -
> 
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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080417/7660fef9/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: image.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080417/7660fef9/attachment.gif>
