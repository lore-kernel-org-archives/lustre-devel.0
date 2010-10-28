From: LEIBOVICI Thomas <thomas.leibovici@cea.fr>
Date: Thu, 28 Oct 2010 15:43:19 +0200
Subject: [Lustre-devel] changelog for whole filesystem?
In-Reply-To: <9759789F-8FD0-464F-9632-E31F0F45287C@oracle.com>
References: <855B43E2-1D24-4095-ABE7-643A3ADAD67D@oracle.com>
	<4CC84509.4050609@cea.fr>
	<9759789F-8FD0-464F-9632-E31F0F45287C@oracle.com>
Message-ID: <4CC97DF7.8040206@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On 2010-10-27, at 23:28, LEIBOVICI Thomas <thomas.leibovici@cea.fr> wrote:
>   
>> Would this special log have the same record structure as current changelogs, or a different structure with more information?
>> Depending on how this iterator works, maybe we can avoid RPCs (for stat, fid2path, get_stripe, hsm_state_get...) if this info is available when the log record is generated.
>>     
>
> My thought was to use the same format for the changelog so that it would be easy to use the same API to use the "whole filesystem" traversal log and then transfer over to the standard "changes only" changelog. In fact, it might make sense to make this atomic so that this is a flag on a regular changelog open, and it will continue after the traversal is completed to the changelog for any changes that happened since the traversal started. 
>   
OK, I got it. So the idea is to have a switch in the policy engine that 
would be:
- if it starts for the first time => open the changelog with a special 
flag to get all entries + changes in the meanwhile
- else => open the changelog as usual

"any changes that happened since the traversal started"

A couple of comments about that:
- With the current implementation, the ChangeLog transaction management starts after the "changelog_register" on MDT,
then the log records start accumulating on MDT until they are read and acknowledged by the consummer.
So, reporting only the "changes that happened since the traversal started" implies to voluntarily forget previous records
that were waiting to be read.
- if changes occur during the scan: do we skip/ignore records for entries that have not been listed yet?
- If we want to make the "scan log" restartable from the last read entry, the client should be able to reopen the log
by giving the last record id in argument and continue the scan and/or the standard log records where it stopped.
So merging the 2 log streams (scan and standard changelog) may imply a common record id management.

Distinguishing the two kind of logs depending on open flag makes it possible
to manage log record index and scan record index separately, which would simplify the implementation:
the record index for "scan log" will be something like the inode-number order,
and the log consummer can use this index for restarting an aborted scan.

Once the changelog consummer is registered on MDT, we are sure not to miss any change that occurs on the filesystem.
So, for initializing the HSM policy engine DB, we can proceed the following way:
1) register a changelog consummer on MDT
2) open and process the "scan log"
3) open and process the standard changelog records that are accumlated since step 1)
we are sure to know all entries in filesystem after those 3 steps.
Policy engine can actually perform 3) at any time. The only contain is to have step 1) before step 2).

Thomas.
