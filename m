From: Shipman, Galen M. <gshipman@ornl.gov>
Date: Fri, 23 Jan 2009 12:39:43 -0500
Subject: [Lustre-devel] SAM-QFS, ADM, and Lustre HSM
References: <EB7E4462-1CFF-4CCD-A38F-AE4D89108B59@Sun.COM>
	<3DF0F4AF-F4D6-476E-98F7-CD912C49FC18@Sun.COM>
	<2734A30F-2C76-4725-9F3A-29AD4245B7E8@Sun.COM>
	<496FCA67.6000500@sun.com>
	<48D329C0-242E-4A5A-94C1-DF493BB25C2F@Sun.COM>
	<496FE8D4.2090908@sun.com>
	<BEB67402-7AFE-4BE1-A59C-050823AFC8E5@Sun.COM>
	<4977647D.5010503@sun.com>
	<4977E5BD.7000706@sun.com> <4978DB1E.30507@sun.com>
	<20090122225512.GP3652@webber.adilger.int>
Message-ID: <537C6C0940C6C143AA46A88946B854170D40BE5B@ORNLEXCHANGE.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Looks like HPSS will support EA in 7.1.2.0, June 2009
I have asked Vicky here at ORNL to dig a bit into what the EA features will look like. 
Do we have a set of requirements for EAs for HSM integration?


- Galen 



-----Original Message-----
From: Andreas.Dilger@sun.com on behalf of Andreas Dilger
Sent: Thu 1/22/2009 5:55 PM
To: Nathaniel Rutman
Cc: Hua Huang; lustre-hsm-core-ext at sun.com; lustre-devel at lists.lustre.org; Karen Jourdenais; Erica Dorenkamp; Harriet.Coverston at sun.com; Rick Matthews; karl at tacc.utexas.edu
Subject: Re: SAM-QFS, ADM, and Lustre HSM
 
On Jan 22, 2009  12:46 -0800, Nathaniel Rutman wrote:
> QFS has a Linux native client  
> So the copy nodes would be linux nodes acting as clients for both Lustre  
> and QFS.  This would generally result in two network hops for the data,  
> but by placing the clients on OST nodes and having the coordinator  
> choose wisely, we can probably save one of the network hops most of the  
> time.  This may or may not be a good idea, depending on the load imposed  
> on the OST.  The copytool would also require us to pump the data from  
> kernel to userspace and back, potentially resulting in significant bus  
> loading.  We could memory map the Lustre side

I was just wondering to myself if we couldn't make an optimized "cp"
command that would work in the kernel and be able to use newer APIs
like "splice" or just a read-write loop that avoids kernel-user-kernel
data copies.  Unfortunately, I don't think mmap IO is very fast with
Lustre, or memcpy() from mmap Lustre to mmap QFS would give us a single
memcpy() operation (which is the best I think we can do).

> There are two items that I can think of that may be archive-specific
> 1. hash the fids into dirs/subdirs to avoid a big flat namespace
> 2. inclusion of file extended attributes (EAs)
> But in fact, I don't know enough about HPSS to say we don't need these  
> items anyhow.  CEA, can you comment?
> I think current versions of HPSS are able to store EAs automatically,  
> and QFS is not, so that may be one difference.

I got a paper from CEA that indicated HPSS was going to (or may have
already) implemented EA support, but it isn't at all clear if that
version of software would be available at all sites, since AFAIK it
is relatively new.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
