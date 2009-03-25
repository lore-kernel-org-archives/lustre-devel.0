From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Wed, 25 Mar 2009 11:17:48 +0300
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <0B02BFB6-2461-48E7-A572-946898BAC9B0@sun.com>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
	<0B02BFB6-2461-48E7-A572-946898BAC9B0@sun.com>
Message-ID: <200903251117.48986.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 24 March 2009 02:17:33 Robert Read wrote:
> Hi Zam,

> > MD update: a part of MD operation to be executed on one server,
> > contains one or more MDS/RAW operations.
>
> Why does the client need to to be more granular than an update?  It
> seems MDS/Raw and update should be the same.

well, better to say an update is MDS op if the operation touch only one 
MD server and MDS/Raw op in case of distributed operation.

> > MD batch: a collection of per-server MD updates.
> >
> > MDTR: MD translator: translates MD operations into MD/Raw ones.
>
> Isn't this essentially what the cmm is doing today? (Breaking down
> distributed operations into per-node updates?)  Are you expanding on
> Alex's idea of creating a new generic MD server stack?

I just doubt that cmm code reuse is worth MD stack relayering. Can it be 
done as a subtask later?

> > *** WBC protocol
> >
> > WBC request contains a set of MD/RAW operations, tagged with one
> > epoch number.  Bulk transfers are used.
>
> All the updates in a single operation must have the same epoch, but I
> don't think we can guarantee that all the operations in a batch will
> be in the same epoch, unless we stop exchanging messages with all the
> MD servers. I don't see a need for them to be in the same epoch,
> either.

you are right.

> > *** File data
> > Flushing file data to the OST servers is delayed until file
> > creation is re-integrated.
> >
> > *** Recovery
> >
> > The redo-log preserved until it is not needed in recovery (i.e.
> > epoch gets stable)
> >
> > Client replay the log and re-execute all operations from it,
> > repeating MDTR processing (dispatching the operation between MD
> > servers).
>
> Since the MD servers all roll back before recovery, recovery will be
> very similar to the original reintegration, with the exception of
> using versions.  So we should try to keep the recovery (replay) code
> as similar to the normal code as possible, and move recovery higher
> into the stack.

ok.

> > **** WBC client eviction, uncompleted updates
> >
> > If client dies until re-integration is completed, there are three
> > choices:
> >
> > a) Cluster-wide rollback, all servers roll back to the last
> > globally stable epoch, then clients to replay heir redo-logs.
> >
> > This scenario should be avoided because a single client failure may
> > may stop whole cluster for recovery.
> >
> > b) All servers participating in re-integration coordinate to undo
> > uncompleted updates.
> >
> > c) The servers have all information needed to complete
> > re-integration w/o client.
>
> You mean by keeping the original operation info in the undo logs?

I meant the servers receive not updates but whole operations. If the 
client failed and didn't send an update to some of the servers, the 
operation can be completed w/o the client. It is an alternative to 
undoing of partial updates.

Thanks,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
