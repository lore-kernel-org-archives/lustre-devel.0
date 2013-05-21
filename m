From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Tue, 21 May 2013 11:16:10 -0700
Subject: [Lustre-devel] lustre kernel configuration
In-Reply-To: <519B8099.7010803@lanl.gov>
References: <5a77f40fe7860376e5bcdfaeb8e6cb7a.squirrel@webmail.andrew.cmu.edu>
	<20130513213454.GF7378@llnl.gov>
	<E0341800-5675-434B-9F1F-AB01C7B3950C@intel.com>
	<519B8099.7010803@lanl.gov>
Message-ID: <519BB9EA.70304@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

If you use the zfs osd for your servers, there is no need to modify your 
Linux kernel.  That is probably a much easier way to get started with 
Lustre development.

If you are set on using the ldiskfs osd, Intel has some instructions on 
their wiki here:

   https://wiki.hpdd.intel.com/display/PUB/Building+Lustre+from+Source

Chris

On 05/21/2013 07:11 AM, Ron Croonenberg wrote:
> hello,
>
> I am looking into some Lustre development but want to build everything
> from scratch. I looked around to see how the linux kernel is configured
> but don't seem to find anything.
>
> any ideas?
>
> thanks,
>
> Ron
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
