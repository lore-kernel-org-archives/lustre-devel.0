From: NeilBrown <neilb@suse.com>
Date: Thu, 28 Jun 2018 11:17:03 +1000
Subject: [lustre-devel] [PATCH v3 07/26] staging: lustre: libcfs: NUMA
 support
In-Reply-To: <DM3PR1101MB1213FD1001256E565FF011FFCB480@DM3PR1101MB1213.namprd11.prod.outlook.com>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-8-git-send-email-jsimmons@infradead.org>
 <877emnaed8.fsf@notabene.neil.brown.name>
 <A764DED1-A9A8-4FA5-A0F1-922C3E2D822A@cray.com>
 <87lgb16j8q.fsf@notabene.neil.brown.name>
 <DM3PR1101MB1213FD1001256E565FF011FFCB480@DM3PR1101MB1213.namprd11.prod.outlook.com>
Message-ID: <8736x77lrk.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


I went digging and found that Linux already has a well defined concept
of distance between NUMA nodes.
On x86 (and amd64?), this is loaded from ACPI.  Other platforms can
describe it in devicetree.
You can view distance information in
  /sys/devices/system/node/node*/distance

or using "numactl --hardware".

Why doesn't lustre simple extract and use this information?  Why does
lustre need to allow it to be configured?

Thanks,
NeilBrown

On Wed, Jun 27 2018, Patrick Farrell wrote:

> Neil,
>
> I am not the person at Cray for this, but if SUSE does take an interest in this, Cray would probably be interested in weighing in and contributing info if not actually code.  In fact, other HPC vendors like HPE(by which I mostly mean the old SGI) or IBM might as well.  NUMA optimization is a persistent fascination in our area of the industry...
>
> - Patrick
>
> ________________________________
> From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
> Sent: Tuesday, June 26, 2018 9:44:37 PM
> To: Doug Oucharek
> Cc: Amir Shehata; Lustre Development List
> Subject: Re: [lustre-devel] [PATCH v3 07/26] staging: lustre: libcfs: NUMA support
>
> On Mon, Jun 25 2018, Doug Oucharek wrote:
>
>> Some background on this NUMA change:
>>
>> First off, this is just a first step to a bigger set of changes which include changes to the Lustre utilities.  This was done as part of the Multi-Rail feature.  One of the systems that feature is meant to support is the SGI UV system (now HPE) which has a massive number of NUMA nodes connected by a NUMA Link.  There are multiple fabric cards spread throughout the system and Multi-Rail needs to know which fabric cards are nearest to the NUMA node we are running on.  To do that, the ?distance? between NUMA nodes needs to be configured.
>>
>> This patch is preparing the infrastructure for the Multi-Rail feature to support configuring NUMA node distances.  Technically, this patch should be landing with the Multi-Rail feature (still to be pushed) for it to make proper sense.
>>
>
> Thanks a lot for the background.
>
> If these NUMA nodes have a 'distance' between them, and if lustre can
> benefit from knowing the distance, then is seems likely that other code
> might also benefit.  In that case it would be best if the distance were
> encoded in some global state information so that lustre and any other
> subsystem can extract it.
>
> Do you know if there is any work underway by anyone to make this
> information generally available?  If there is, we should make sure that
> lustre works in a compatible way so that once that work lands, lustre
> can use it directly and not need extra configuration.
> If no such work is underway, then it would be really good if something
> were done in that direction.  If no-one here is able to work on this, I
> can ask around in SUSE and see if anyone here knows anything relevant.
>
> Thanks,
> NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180628/2e5f3d39/attachment.sig>
