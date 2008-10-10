From: Eric Barton <eeb@sun.com>
Date: Fri, 10 Oct 2008 21:11:32 +0100
Subject: [Lustre-devel] proposal to increase seek in sgpdd_survey
In-Reply-To: <1223665357.11840.138.camel@brian-laptop>
References: <1222817771.26779.75.camel@pc.ilinx>
	<244CBACA73094649889DFE28A43F7B2E@ebpc>
	<1223665357.11840.138.camel@brian-laptop>
Message-ID: <BC160A91CD43413FB9B898E767854EC2@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Brian,

> Just for clarification Eric...  Are you advocating num_gaps ==
> num_regions or num_gaps == num_regions-1?  i.e. in a two region test
> should the second region start at 50% of the disk or 100%-$region_size
> so that the last byte of the second region is written to the last byte
> of the disk?
> 
> It seems to me that the first option provides a more "middle of the
> road" (which might correlate to real-world averages more closely)
> average as it only incorporates a seek of half the disk whereas the
> second option provides a more worst case performance result.

Not quite so bothered by that and it gets less intersting with more
regions.  Maybe leave it in as a non-default option, in case it's
a real disk killer.

    Cheers,
              Eric
