From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Fri, 29 Apr 2011 10:35:22 -0700
Subject: [Lustre-devel] F/S stats visualisation
In-Reply-To: <008a01cc05f8$a6b26840$f41738c0$@com>
References: <008a01cc05f8$a6b26840$f41738c0$@com>
Message-ID: <73AED5C780AE05478241DB067651A921023784B9@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

That's interesting - why do you think opens >> closes?
Are we not tracking closes correctly?

On Apr 28, 2011, at 4:04 PM, Eric Barton wrote:

> Hi,
> 
> I've made some histograms that visualise the F/S stats people have
> so kindly sent in.  There are a couple of surprises which seem to
> do with how the filesystems were set up (e.g. huge #s of inodes
> reserved but not used on OSTs) and used (different ratios of ops).
> 
> The attached PDF has a summary for each filesystem containing...
> 
> * Filesystem name
> 
> * Ratio of MDS 1K blocks to MDS inodes
>  Ratio of OST 1K blocks to MDS inodes
>  Ratio of OST inodes to MDS inodes
> 
> * Histogram of operation counts
> 
> * Histogram of blocks total (blue) and used (red) on the MDS
>  and all OSTs
> 
> * Histogram of inodes total (blue) and used (red) on the MDS
>  and all OSTs 
> 
> ...hope you find it useful.
> 
>          Cheers,
>                   Eric
> 
> 
> <Lustre stats.pdf>_______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
