From: Simmons, James A. <simmonsja@ornl.gov>
Date: Thu, 2 Jul 2015 20:46:24 +0000
Subject: [lustre-devel] DNE2 feature patch landing
In-Reply-To: <1435865147.2548.26.camel@intel.com>
References: <1435865147.2548.26.camel@intel.com>
Message-ID: <aefb17439e2d4164b318a5e05c8695c0@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>All,
>
>Last week a patch landed conflicting with the DNE2 project that was
>preparing to land for 2.8:
>http://wiki.lustre.org/Projects
>
>The DNE2 feature patches were rapidly re-based, re-reviewed and prepared
>again for landing. However, a unrelated test failure from the continuous
>integration environment has delayed the landing of these three patches
>beyond the feature freeze date of June 30th.
>
>We anticipate that it would only take an extra day or two to get the
>outstanding DNE2 patches landed and recommend that we extend the feature
>freeze  for these to allow this OpenSFS-funded project to complete.  We
>do not expect this to have a material affect on the 2.8 release date.
>
>I'm asking the list now for a couple of supporting community voices to
>endorse this request.

We had this discussion at the last OpenSFS working group which we agreed
that the patch for LU-3534 should land after the feature freeze. Before the
merge conflict the patch did pass all maloo test and had the needed reviews.
The merge conflict was due to another change that landed that altered one
of the test in the test suite. So their is no C code change between versions of
the LU-3534 patch. The rest of the patches are fixes for bug so they fall into
the bug fixing phase.
