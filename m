From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Thu, 24 Jun 2010 12:36:56 -0600
Subject: [Lustre-devel] Contributing to Lustre fs
In-Reply-To: <AANLkTin0n0dW60VkngADsWlgly6pw0yLsQGF8H-dSkQ6@mail.gmail.com>
References: <AANLkTikGatxq94h7ScVeaVUyXf-cDGThG3ok6mNvsSYL@mail.gmail.com>
	<6F051193-EDC4-443B-A73B-5ED70F967BDA@oracle.com>
	<AANLkTimefDl53Br5yGji9Vgq0G2QJ-xbmddb8LF02vkR@mail.gmail.com>
	<AANLkTin0n0dW60VkngADsWlgly6pw0yLsQGF8H-dSkQ6@mail.gmail.com>
Message-ID: <3023F64D-1AB3-445E-90E4-07FB4AED59B0@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I believe that Wang Di has already done a considerable amount of work related to this in his CMD branch. 

If you (or anyone) is looking for 'starter' bugs you can search in bugzilla for bugs with the 'easy' keyword. I mark this on bugs that I find which are relatively straight forward and/or bugs which are mostly finished with a patch but just need a patch update and some testing. 

Cheers, Andreas

On 2010-06-23, at 11:03 PM, Onkar Mahajan <kern.devel@gmail.com> wrote:

> Hi, 
> 
> Is there anything remaining to be done here 
> is nay R&D required here :
> 
> https://bugzilla.lustre.org/show_bug.cgi?id=16299
> 
> regards,
> Onkar
> 
> 
> On Thu, Jun 24, 2010 at 9:37 AM, Onkar Mahajan <kern.devel@gmail.com> wrote:
> Thank you very much Andreas for your support. 
> I am new to Lustre and highly motivated to put efforts to 
> understand & contribute to it. 
> As a starting point can you suggest me some low 
> priority enhancement that I can do research on , provide 
> some solution, and use to get familiarize with Lustre. 
> This is a small request. 
> 
> 
> Regards,
> Onkar
> 
> 
> 
> 
> On Thu, Jun 24, 2010 at 12:16 AM, Andreas Dilger <andreas.dilger@oracle.com> wrote:
> On 2010-06-23, at 11:18, Onkar Mahajan wrote:
> >        Can only Sun (Oracle) employees contribute to lustre ? Bug fixes are
> > done by Sun (Oracle ) employees only ?
> 
> We're thrilled to have external contributors to Lustre, believe me. :-)  There are unfortunately all too few people that do contribute.  Bull, CEA, LLNL, ORNL, DDN are the main ones, off the top of my head, sorry if I missed others.  I think this is mostly due to the complexity and lack of documentation.  We're working on improving the code commenting so hopefully the code will become more accessible in the future.
> 
> Please see the following pages for more details:
> 
> http://wiki.lustre.org/index.php/Contribution_Policy
> http://wiki.lustre.org/index.php/Submitting_Patches
> 
> It is best to discuss any major contributions you are working on in advance, so that we can guide you to develop code that we will include into the release, since there may be different reasons why one solution is better than another (e.g. aligning better with in-progress or future features, fixing other bugs in the same area, etc).
> 
> Usually we need a patch to be attached to a bug in bugzilla in order to track its inspection, testing, and inclusion into a release.  Before filing a new bug, searching in Bugzilla for an existing bug and/or asking here is important, since there are already many "feature/improvement" bugs open that discuss issues and suggest implementations for proposed changes.
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Technical Lead
> Oracle Corporation Canada Inc.
> 
> 
> 
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100624/3edf11ae/attachment.htm>
