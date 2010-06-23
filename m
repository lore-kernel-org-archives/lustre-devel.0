From: Andreas Dilger <andreas.dilger@Oracle.Com>
Date: Wed, 23 Jun 2010 12:46:35 -0600
Subject: [Lustre-devel] Contributing to Lustre fs
In-Reply-To: <AANLkTikGatxq94h7ScVeaVUyXf-cDGThG3ok6mNvsSYL@mail.gmail.com>
References: <AANLkTikGatxq94h7ScVeaVUyXf-cDGThG3ok6mNvsSYL@mail.gmail.com>
Message-ID: <6F051193-EDC4-443B-A73B-5ED70F967BDA@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-06-23, at 11:18, Onkar Mahajan wrote:
>        Can only Sun (Oracle) employees contribute to lustre ? Bug fixes are 
> done by Sun (Oracle ) employees only ?

We're thrilled to have external contributors to Lustre, believe me. :-)  There are unfortunately all too few people that do contribute.  Bull, CEA, LLNL, ORNL, DDN are the main ones, off the top of my head, sorry if I missed others.  I think this is mostly due to the complexity and lack of documentation.  We're working on improving the code commenting so hopefully the code will become more accessible in the future.

Please see the following pages for more details:

http://wiki.lustre.org/index.php/Contribution_Policy
http://wiki.lustre.org/index.php/Submitting_Patches 

It is best to discuss any major contributions you are working on in advance, so that we can guide you to develop code that we will include into the release, since there may be different reasons why one solution is better than another (e.g. aligning better with in-progress or future features, fixing other bugs in the same area, etc).

Usually we need a patch to be attached to a bug in bugzilla in order to track its inspection, testing, and inclusion into a release.  Before filing a new bug, searching in Bugzilla for an existing bug and/or asking here is important, since there are already many "feature/improvement" bugs open that discuss issues and suggest implementations for proposed changes.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
