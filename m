From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Thu, 02 Jul 2015 13:58:11 -0700
Subject: [lustre-devel] DNE2 feature patch landing
In-Reply-To: <aefb17439e2d4164b318a5e05c8695c0@EXCHCS32.ornl.gov>
References: <1435865147.2548.26.camel@intel.com>
	<aefb17439e2d4164b318a5e05c8695c0@EXCHCS32.ornl.gov>
Message-ID: <5595A5E3.2060201@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 07/02/2015 01:46 PM, Simmons, James A. wrote:
>> All,
>>
>> Last week a patch landed conflicting with the DNE2 project that was
>> preparing to land for 2.8:
>> http://wiki.lustre.org/Projects
>>
>> The DNE2 feature patches were rapidly re-based, re-reviewed and prepared
>> again for landing. However, a unrelated test failure from the continuous
>> integration environment has delayed the landing of these three patches
>> beyond the feature freeze date of June 30th.
>>
>> We anticipate that it would only take an extra day or two to get the
>> outstanding DNE2 patches landed and recommend that we extend the feature
>> freeze  for these to allow this OpenSFS-funded project to complete.  We
>> do not expect this to have a material affect on the 2.8 release date.
>>
>> I'm asking the list now for a couple of supporting community voices to
>> endorse this request.
>
> We had this discussion at the last OpenSFS working group which we agreed
> that the patch for LU-3534 should land after the feature freeze. Before the
> merge conflict the patch did pass all maloo test and had the needed reviews.
> The merge conflict was due to another change that landed that altered one
> of the test in the test suite. So their is no C code change between versions of
> the LU-3534 patch. The rest of the patches are fixes for bug so they fall into
> the bug fixing phase.

On the contract call today we encouraged Intel to have this conversation 
and make this decision more publicly.  The LWG calls are only attended 
by a small fraction of the development community.  I think it is 
important that we start being more open and transparent with the 
activities and decisions surrounding Lustre's master branch.

So thanks, Richard for posting on lustre-devel.

Since this feature has been developed under the old style of piecemeal 
landing rather than the new topic branch development style, I too agree 
that landing this after the feature freeze date is acceptable.

Chris
