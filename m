From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Tue, 19 Feb 2008 18:13:09 +0100
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <537C6C0940C6C143AA46A88946B854170C2EFE91@ORNLEXCHANGE.ornl.gov>
References: <47AAE307.9040305@cea.fr>
	<537C6C0940C6C143AA46A88946B854170C2EFE91@ORNLEXCHANGE.ornl.gov>
Message-ID: <47BB0E25.3090607@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Canon, Richard Shane a ?crit :
> General
> * Any thought on how quotas will be handled?

That's a very good question.
I think this point should be discussed.

The purge possibility introduces two values which could be under quota.
  1 - File size (current case)
  2 - The disk occupation are used (migrated files free quota)

The first point are the simplest to implement and will need fewer
modifications, but users could not free quota even if all their files
are migrated.
The second point could help users but this will be problematic when they
will copy back some of their file, because this will trigger space
issues and purge requests on theirs other files, and so on.

IMO, the best way is to take choice #1 and possibly add a 'real disk
use' quota value that could be tuned by admins.

I'm not a Lustre quota specialist and AFAIK this code is a bit touchy.


> Coordinator
> * 3.4 - I was curious what the precise use case was that was driving
> this?  I don't disagree with it, but I was curious for more background

Coordinator is designed to also manage internal Lustre migrations.

> * 3.7.1 - The coordinator could become a scaling bottleneck.  We should
> think about how this will be scaled in the future

I think we should be able to have several coordinators in the future.
Each of them dealing with different external storages.

> * 4.1 - Does the coordinator store the ext obj id or does the agent

The agent does not have a storage device. It stores nothing.
The external IDs are in MDT device.

> * 4.3 item 2 - This looks like the coordinator could become a bottle
> neck for unlinks and slow down performance.  Could this be put in some
> type of async queue to be processed later (or some type of attic space)?

Yes, I think unlinks should be handled asynchronously.

> Use Cases
> * 2.3 (Use cases) - I'm really keen on this feature.  I think it is very
> important in order to make small file performance work well.
> Unfortunately, it isn't clear how the file list gets communicated to the
> archive tool.  The coordinator and agent seem to only take one file at a
> time.  So how would this work exactly?

In fact, we have presently designed the archiving tool to support this
feature and only it because the archiving tool could be developped by
anyone and we want this API being as stable as possible. The current
Lustre component design does not handle it. But it will be added later,
in a second step, and the copy tool developped since will be already
compatible with it.

> * 2.4 - The copy tool should be allowed to preemptively restage files.
> I think this will work with the design, but we should make sure of this.
> This would be useful for restaging a whole tar file versus doing things
> piece-meal.

That's an interesting point. I think we could avoid it but it is an
interesting feature. I must think how we should modify the design to
permit it. (The tool should be able to warn the coordinator: oh, i'm
staging this file also! please note it)

> 2 EAs - I'm worried that the EA list could get huge for holes.

This part has been redesigned. The data that were stored in EA have been
moved. It will be explained in the new document version.

> 3.2 -item 3 - Who insures a file is archived before punches are made?

The space manager did it. It is the only one which will make punch
request. May be MDT could ensure it before dealing with it.

> 3.3 - Another use case...  The user checks to see if a file has been
> archived.

Ok

> Also, someone earlier made the point about the archive tool being able
> to reorder request.  This is really important since an archival system
> wants to know all the files being restaged in order to order tape mounts
> and reads.  

I do not see any problem with this.
I will add this point in the doc.


> Thanks for taking the lead on this.  It looks like there is a lot of
> interest in it.

Thanks you for your very interesting comments.


-- 
Aurelien Degremont
CEA
