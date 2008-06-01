From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Sun, 01 Jun 2008 11:03:03 +0400
Subject: [Lustre-devel] Commit on share
In-Reply-To: <20080531024524.GB2992@webber.adilger.int>
References: <C4620704.5499%peter.braam@sun.com> <op.ubxfheh9atmt0c@goga>
	<20080531024524.GB2992@webber.adilger.int>
Message-ID: <op.ub15vdu9atmt0c@goga>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, 31 May 2008 06:45:24 +0400, Andreas Dilger <adilger@sun.com> wrote:

> On May 29, 2008  21:42 +0400, Mike Pershin wrote:
>> The only positive effect of ACK is delay before doing sync, that give us
>> the chance to wait for commit without doing force sync. But that can be
>> done with timer to get the same results.
>
> On a related note - I just came across bug 3621 - sync outstanding
> transaction instead of evicting client when a rep-ack isn't received.
> Could you please address this bug at the same time as COS.  With COS
> this will always happen, of course, but it should also happen without
> it to avoid client eviction if possible.
>

OK

> RepACK is currently needed for recovery.  I don't think it is a false
> conflict in most cases, though I agree in some cases it is.  If MDS
> thread is only e.g. passing through a directory to do some operation
> in a previously-existing subdirectory, or wants to stat a file that
> existed before the conflicting lock was taken then this is a false
> dependency.

RepACK is not needed for recovery if COS is enabled, because COS will sync  
the share cases so there is no need to be sure that client got reply and  
will do replay as there are no dependent replays on it.
Also the cases are creations from different clients or unlinks (operations  
of same type). They are not dependent actually, the only dependency here  
may be create vs unlink or unlink vs create. Currently such cases are not  
distinguished and we block access for any operation from different client.

>
>> Moreover it conflicts in general with dependency tracking we needed,
>> because it will serialize operations even when they may not depend.
>>
>> With RepACK lock we are entering in operation AFTER the checks and we
>> don't know the result of this check - was there operation from different
>> client? are changes committed? Should we do sync or not? RepACK lock
>> doesn't answer this question and we can't decide about sync is needed or
>> not.
>
> That isn't quite true - if the changes ARE already committed, then the
> lock is no longer needed and dropped by the commit callback.

Indeed. But I were talking about different thing. When we pass lock (enter  
the locked area) then we don't know was the lock taken at all or not? Was  
it dropped due to commit or ACK received? So we don't know should we do  
commit or it was done already or it is not needed at all. Maybe we may use  
uncommitted_replies list to determine that, but it is not perfect way too.

>> 3) But we don't know still is there conflict or not because we should
>> check client uuids, but we don't store such info anywhere and waiting on
>> lock is not reflected somehow. So we need extra data (or extra  
>> information
>>   from ldlm?) again to store uuid of client who did latest operation on  
>> that
>> object.
>
> Wouldn't that be in the last_rcvd data for the current client?  If the
> req->rq_export->exp_mds_data->med_mcd->mcd_last_transno is the same as
> the VBR transno on object being modified then we know this client was
> the last one to modify the object and there is no external dependency.
>
but this stops working if last_transno is bigger that object version. Then  
we lost info about who set than version.

>> hash table store the following data per object:
>> struct lu_dep_info {
>>           struct ll_fid     di_object;
>>           struct obd_uuid   di_client;
>>           __u64             di_transno;
>> };
>>
>> it contains uuid of client and transno of last change from this client.
>> The uuid is compared to determine is there is conflict of not, the  
>> transno
>> shows was that data committed already or not. I described above why it  
>> is
>> needed. It is 1.6-related issue because we have only inode of object and
>> no any extra structure. The HEAD has lu_object enveloping inodes, and  
>> hash
>> will not needed, the dependency info may be stored per lu_object.
>
> I think the commit callbacks should be able to free this data, there
> should never be any such items on an object with di_transno >  
> last_committed.

you mean the moment of commit? As I know the new journal_start() may start  
after last batch is committed but before commit callbacks will be invoked.  
So the new dep_info may occur with di_transno > last_committed, and we may  
not free all dep_info at once in commit callback, but should distinguish  
new from old. The good thing to have would be some notification from  
ldiskfs about batch boundary but this is good in theory only.

> Also, isn't it enough to store a single such item per object directly
> on the object?  Once we know there is ANY such conflict that is enough
> to invoke COS.  For per-object data this can be stored on 1.6 in the
> i_filterdata structure that we can attach onto every server inode.
It is per-object, yes. And this is very valuable advice about  
i_filterdata. I thought we have no access to inode_info from upper level  
at server side. This will reduce need for hash at all and simplify things  
a lot.

>
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel



-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
