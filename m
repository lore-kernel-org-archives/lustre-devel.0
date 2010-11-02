From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Tue, 2 Nov 2010 00:42:06 -0600
Subject: [Lustre-devel] changelog for whole filesystem?
In-Reply-To: <022a01cb7789$55cc7a40$01656ec0$@com>
References: <855B43E2-1D24-4095-ABE7-643A3ADAD67D@oracle.com>
	<4CC84509.4050609@cea.fr>
	<9759789F-8FD0-464F-9632-E31F0F45287C@oracle.com>
	<4CC97DF7.8040206@cea.fr> <022a01cb7789$55cc7a40$01656ec0$@com>
Message-ID: <2E7B2EC5-BDCB-41A4-A566-42EC7A72943C@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-10-29, at 10:50, Eric Barton wrote:
> I _do_ like the idea of opening the changelog to see changes either
> "from now" or "from empty".   But I think the idea needs to worked
> out fully to support multiple changelog consumers

Definitely.  Since the "from empty" iterator is a virtual iterator in the first place, it seems relatively easy to have a separate iteration index for each one.  The harder part is how to integrate the virtual filesystem iteration.

> - e.g. how to keep
> multiple placeholders in the object enumeration so that changes to
> objects yet to be enumerated for a particular consumer are not queued
> to that consumer.

I was initially thinking that all filesystem events would be queued for each "from empty" iterator, for processing after the full filesystem iteration has completed.  There would be some potential inconsistencies (e.g. creation events for inodes that were iterated, or deletion events for inodes that were not iterated).

This is no worse than doing the iteration with an external tool - if the filesystem is "live" the tool would need to handle these inconsistencies, and if it is offline for the initial iteration there are no inconsistencies.

However, it would also seem possible to use the current inode iteration index as a filter to only keep events for inodes beyond the current index (possibly in a per-consumer log if there are multiple consumers).

> As ever, I'm concerned that what looks like "low
> hanging fruit" now later turns into technical debt later.

Potentially, yes, which is why I brought it up for discussion.  I definitely think that having a single interface for filesystem iteration makes much more sense than having to traverse the filesystem with an external tool and only then start to use changelogs.

>> -----Original Message-----
>> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf
>> Of LEIBOVICI Thomas
>> Sent: 28 October 2010 6:43 AM
>> To: Andreas Dilger
>> Cc: lustre-hsm-core-ext at Sun.COM; lustre-devel at lists.lustre.org List
>> Subject: Re: [Lustre-devel] changelog for whole filesystem?
>> 
>> Andreas Dilger wrote:
>>> On 2010-10-27, at 23:28, LEIBOVICI Thomas <thomas.leibovici@cea.fr> wrote:
>>> 
>>>> Would this special log have the same record structure as current changelogs, or a different
>> structure with more information?
>>>> Depending on how this iterator works, maybe we can avoid RPCs (for stat, fid2path, get_stripe,
>> hsm_state_get...) if this info is available when the log record is generated.
>>>> 
>>> 
>>> My thought was to use the same format for the changelog so that it would be easy to use the same API
>> to use the "whole filesystem" traversal log and then transfer over to the standard "changes only"
>> changelog. In fact, it might make sense to make this atomic so that this is a flag on a regular
>> changelog open, and it will continue after the traversal is completed to the changelog for any changes
>> that happened since the traversal started.
>>> 
>> OK, I got it. So the idea is to have a switch in the policy engine that
>> would be:
>> - if it starts for the first time => open the changelog with a special
>> flag to get all entries + changes in the meanwhile
>> - else => open the changelog as usual
>> 
>> "any changes that happened since the traversal started"
>> 
>> A couple of comments about that:
>> - With the current implementation, the ChangeLog transaction management starts after the
>> "changelog_register" on MDT,
>> then the log records start accumulating on MDT until they are read and acknowledged by the consummer.
>> So, reporting only the "changes that happened since the traversal started" implies to voluntarily
>> forget previous records
>> that were waiting to be read.
>> - if changes occur during the scan: do we skip/ignore records for entries that have not been listed
>> yet?
>> - If we want to make the "scan log" restartable from the last read entry, the client should be able to
>> reopen the log
>> by giving the last record id in argument and continue the scan and/or the standard log records where
>> it stopped.
>> So merging the 2 log streams (scan and standard changelog) may imply a common record id management.
>> 
>> Distinguishing the two kind of logs depending on open flag makes it possible
>> to manage log record index and scan record index separately, which would simplify the implementation:
>> the record index for "scan log" will be something like the inode-number order,
>> and the log consummer can use this index for restarting an aborted scan.
>> 
>> Once the changelog consummer is registered on MDT, we are sure not to miss any change that occurs on
>> the filesystem.
>> So, for initializing the HSM policy engine DB, we can proceed the following way:
>> 1) register a changelog consummer on MDT
>> 2) open and process the "scan log"
>> 3) open and process the standard changelog records that are accumlated since step 1)
>> we are sure to know all entries in filesystem after those 3 steps.
>> Policy engine can actually perform 3) at any time. The only contain is to have step 1) before step 2).
>> 
>> Thomas.
>> 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 


Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
