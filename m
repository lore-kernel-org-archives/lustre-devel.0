From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Mon, 25 Feb 2008 15:44:24 -0700
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <537C6C0940C6C143AA46A88946B854170C2EFE91@ORNLEXCHANGE.ornl.gov>
References: <47AAE307.9040305@cea.fr>
	<537C6C0940C6C143AA46A88946B854170C2EFE91@ORNLEXCHANGE.ornl.gov>
Message-ID: <47C344C8.8090203@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Just a few initial responses from me, I haven't read things 
systematically yet.

Canon, Richard Shane wrote:
> Aurelien and JC,
>
> Sorry that my feedback is late.  Here are my questions/remarks.
>
> General
> * Any thought on how quotas will be handled?
>
>   
This is very very important and will require a lot of detail.  Well 
spotted Shane!!!
> Coordinator
> * 3.4 - I was curious what the precise use case was that was driving
> this?  I don't disagree with it, but I was curious for more background
>   
In internal migrations many objects will be restriped to another set of 
objects to move the data.  The coordinator handles the completion and 
abortion of the agents accomplishing this.
> * 3.7.1 - The coordinator could become a scaling bottleneck.  We should
> think about how this will be scaled in the future
>   
In my writings I was always anticipating a family of load balancing 
coordinators.
> * 4.1 - Does the coordinator store the ext obj id or does the agent
>   
Coordinator, I suggest, in view of the fact that many agents may be 
required to move one file.
> * 4.3 item 2 - This looks like the coordinator could become a bottle
> neck for unlinks and slow down performance.  Could this be put in some
> type of async queue to be processed later (or some type of attic space)?
>
>   
I agree with this.

> Use Cases
> * 2.3 (Use cases) - I'm really keen on this feature.  I think it is very
> important in order to make small file performance work well.
> Unfortunately, it isn't clear how the file list gets communicated to the
> archive tool.  The coordinator and agent seem to only take one file at a
> time.  So how would this work exactly?
> * 2.4 - The copy tool should be allowed to preemptively restage files.
> I think this will work with the design, but we should make sure of this.
> This would be useful for restaging a whole tar file versus doing things
> piece-meal.
>
> Part IV
> 2 EAs - I'm worried that the EA list could get huge for holes.
>   
The EA merely points to an extent tree (similar to the allocation extent 
tree).
> 3.2 -item 3 - Who insures a file is archived before punches are made?
>   
The coordinator.
> 3.3 - Another use case...  The user checks to see if a file has been
> archived.
>
>
> Also, someone earlier made the point about the archive tool being able
> to reorder request.  This is really important since an archival system
> wants to know all the files being restaged in order to order tape mounts
> and reads.  
>
> Thanks for taking the lead on this.  It looks like there is a lot of
> interest in it.
>
> --Shane
>
> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org
> [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of DEGREMONT
> Aurelien
> Sent: Thursday, February 07, 2008 5:53 AM
> To: lustre-devel at lists.lustre.org
> Subject: [Lustre-devel] Lustre HSM HLD draft
>
> Hello
>
> Here is a first draft for comments of the Lustre HSM HLD.
> It is intended to be a support for further analyzes and comments from
> CFS/Sun.
>
> The document covers the main parts of the HSM features but some elements
> are still lacking.
> The policy management and the space manager will be describe later.
>
> Let us know your comments and ideas about it.
>
> Regards,
>
> Aurelien Degremont
> CEA
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
