From: Eric Barton <eeb@sun.com>
Date: Thu, 09 Oct 2008 21:38:38 +0100
Subject: [Lustre-devel] proposal to increase seek in sgpdd_survey
In-Reply-To: <1222817771.26779.75.camel@pc.ilinx>
References: <1222817771.26779.75.camel@pc.ilinx>
Message-ID: <244CBACA73094649889DFE28A43F7B2E@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Brian, Andreas,

I'm cc-ing lustre-devel since this is of general interest.

My comments inline...

> -----Original Message-----
> From: Brian.Murrell at Sun.COM [mailto:Brian.Murrell at Sun.COM] 
> Sent: 01 October 2008 12:36 AM
> To: Andreas.Dilger
> Cc: Eric.Barton at Sun.COM
> Subject: proposal to increase seek in sgpdd_survey
> 
> Andreas, Eric,
> 
> [ I can repost this to lustre-eng or some other place  or to other
> people if you think that a wider/alternate audience is more
> appropriate ]
> 
> We have been asked about considering increasing the seek range on
> multi-region sgpdd_survey tests and I wonder what others' thoughts are.
> 
> Currently, even with multi-region spgdd_survey runs, if the total amount
> of data the survey writes, across all regions is only a small portion of
> the total size of the drive, the results don't factor in what could be
> arguably real world seek penalties on a large drive.
> 
> The proposal is to space out the regions to cover more of the drive.  So
> for example, a 2 region test would write one region at 0% of the drive
> and the second region at 50%.  A 4 region test would write at 0%, 25%,
> 50% and 75%, etc.  Perhaps the inter-region spacing should be such that
> the last byte of the last region is at the end of the disk to maximize
> the seek penalty.  Perhaps not.

Indeed - this is how it should be done.

> In any case, a patch has been submitted in bug 17218 to do just this and
> the reporter's test results and summary are as such:
> 
>         Original test, size=1GB, 128KB reads:
>         0     rd1     rd2     rd4     rd8     rd16    rd32    rd64    
>         1     65.45   -       -       -       -       -       -       
>         2     65.90   18.08   -       -       -       -       -       
>         4     65.98   54.73   20.62   -       -       -       -       
>         8     65.27   64.75   45.56   20.38   -       -       -       
>         16    62.85   59.49   54.38   41.72   20.90   -       -       
>         32    -       58.75   56.54   53.02   38.78   21.94   -       
>         64    -       -       54.47   56.99   52.72   37.94   26.78   
>         128   -       -       -       -       52.22   -       37.84 
>         
>         Original test, size=32GB, 128KB reads (reduced parameters for
>         speed):
>         0     rd1     rd2     rd4     rd8     rd16    rd32    
>         1     -       -       -       -       -       -       
>         2     -       -       -       -       -       -       
>         4     -       -       -       -       -       -       
>         8     -       -       -       -       -       -       
>         16    -       -       -       -       18.96   -       
>         32    -       -       -       -       30.10   20.16   
>         64    -       -       -       -       40.99   -  
>         
>         
>         Modified test, size=1GB, 128KB reads:
>         0     rd1     rd2     rd4     rd8     rd16    rd32    rd64    
>         1     65.00   -       -       -       -       -       -       
>         2     61.65   16.22   -       -       -       -       -       
>         4     57.88   50.18   15.47   -       -       -       -       
>         8     56.95   54.91   47.47   17.09   -       -       -       
>         16    65.54   46.22   51.34   39.85   18.99   -       -       
>         32    -       55.17   51.49   47.62   29.05   19.81   -       
>         64    -       -       50.44   46.41   39.21   26.35   20.23   
>         128   -       -       -       -       -       -       24.74  
>         
>         Modified test, size=32GB, 128KB reads (reduced parameters for
>         speed):
>         0     rd1     rd2     rd4     rd8     rd16    rd32    rd64    
>         1     -       -       -       -       -       -       -       
>         2     -       -       -       -       -       -       -       
>         4     -       -       -       -       -       -       -       
>         8     -       -       -       -       -       -       -       
>         16    -       -       -       -       18.79   -       -       
>         32    -       -       -       -       29.15   19.92   -       
>         64    -       -       -       -       40.90   27.61   20.47
>         
>         
>         Note that these results behave exactly as expected: the 32 GB
>         run is very close to the new 1GB run (and the new 32GB run).
>         The one abnormality, the original 1GB run, has exaggerated
>         performance, and should not be used as it is a very poor
>         predictor of performance.
> 
> So my question for you is, does this proposal match the intent of
> sgpdd_survey or was it intended to be a pure speed measure, minimizing
> seeking cost?

This proposal _totally_ matches the original intent.  This feature of
the current implementation is a bug.  Mea maxima culpa...

    Cheers,
              Eric
