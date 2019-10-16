From: James Nunez <jnunez@whamcloud.com>
Date: Wed, 16 Oct 2019 17:09:06 +0000
Subject: [lustre-devel] [testing] Maloo not scheduling tests
In-Reply-To: <0bc13d64-3def-1ad6-0804-61307ac20209@cea.fr>
References: <c7942901-13ea-6126-5a65-be2271c37f22@cea.fr>
 <FA82114A-33F6-458D-8919-45AE8667EF0A@whamcloud.com>
 <0bc13d64-3def-1ad6-0804-61307ac20209@cea.fr>
Message-ID: <BN8PR19MB3012468EF7F2011D90F6DF84D7920@BN8PR19MB3012.namprd19.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Quentin,

I just checked your patch and the PPC client test session did run; see https://testing.whamcloud.com/test_sessions/6478c83d-a8a5-4d18-8eb6-2242e7590535.

I'm guessing that there may be some confusion on the different test sessions that are run and reported for a patch. If you see posts from "Lustre Gerrit Janitor", this is testing that is not influenced by the test parameters. Meaning that, for your patch, you will not find a PPC test session run and reported by Lustre Gerrit Janitor.

If you see a post from "Maloo", these test results are (or should be) influenced by the patches test parameters.

I think things are working as expected, but feel free to ping me if you disagree and we can investigate.

Thanks,
James

From: lustre-devel [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of quentin.bouget at cea.fr
Sent: Wednesday, October 16, 2019 9:33 AM
To: Andreas Dilger <adilger@whamcloud.com>
Cc: lustre-devel at lists.lustre.org
Subject: Re: [lustre-devel] [testing] Maloo not scheduling tests

On 16/10/2019 17:23, Andreas Dilger wrote:
On Oct 16, 2019, at 19:21, quentin.bouget at cea.fr<mailto:quentin.bouget@cea.fr> wrote:

Hello,
It seems like Maloo is not scheduling tests for this patch<https://review.whamcloud.com/#/c/36292/> since I added some test parameters yesterday:

Test-Parameters: fortestonly testlist=sanity clientarch=ppc64
Are there problems on Maloo, or am I doing something wrong?

The "fortestonly" keyword is for patches that are not intended for landing (e.g. work-in-progress patches for early review), so only a limited number of tests are run.


Yes, I understand this. The idea was to check that the current version of the patch does fail on a big-endian client. But it does not seem like any tests are being scheduled.

EDIT: I just checked gerrit, there must have been a temporary failure, a retest was requested by M. Omstead.

Thanks,
Quentin
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191016/205a0056/attachment-0001.html>
