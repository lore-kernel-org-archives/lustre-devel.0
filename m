From: Shraddha Barke <shraddha.6596@gmail.com>
Date: Tue, 10 Nov 2015 19:03:41 +0530 (IST)
Subject: [lustre-devel] [PATCH] Staging: lustre: lustre_mds: Remove
 unused md_should_create
In-Reply-To: <3ded8eac5c2d43cba0306ac4b052c9e3@EXCHCS32.ornl.gov>
References: <1446889464-21260-1-git-send-email-shraddha.6596@gmail.com>
	<3ded8eac5c2d43cba0306ac4b052c9e3@EXCHCS32.ornl.gov>
Message-ID: <alpine.DEB.2.11.1511101902460.4953@shraddha-370R4E-370R4V-370R5E-3570RE-370R5V>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Tue, 10 Nov 2015, Simmons, James A. wrote:

>> From: lustre-devel [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Shraddha Barke
>> Sent: Saturday, November 07, 2015 4:44 AM
>> To: Greg Kroah-Hartman; lustre-devel at lists.lustre.org
>> Subject: [lustre-devel] [PATCH] Staging: lustre: lustre_mds: Remove unused md_should_create
>>
>> md_should_create has been defined in header file but not used.
>> Thus remove it.
>>
>> Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
>> ---
>> drivers/staging/lustre/lustre/include/lustre_mds.h | 6 ------>
> >1 file changed, 6 deletions(-)
>
> Lustre_mds.h is one of those dysfunctional headers used by client and server code. With the porting
> of some patches and a little rearranging this file could go away.  I'm working out a plan for the pushing
> of the patches and should have it ready in a few days. Basically a lot of work went into cleaning up
> the CLIO client code since the performance was really bad from all the abstraction. You can read
> about it at https://jira.hpdd.intel.com/browse/LU-5880. That work needs very badly merged to  the
> upstream client.

Yes, I'll work on this and send patches.

Kind Regards,

Shraddha
>
>
