From: Vicky White <vyw@ornl.gov>
Date: Thu, 29 Jan 2009 10:36:59 -0500
Subject: [Lustre-devel] SAM-QFS, ADM, and Lustre HSM
In-Reply-To: <20090126195728.GH3652@webber.adilger.int>
References: <2734A30F-2C76-4725-9F3A-29AD4245B7E8@Sun.COM>
	<496FCA67.6000500@sun.com>
	<48D329C0-242E-4A5A-94C1-DF493BB25C2F@Sun.COM>
	<496FE8D4.2090908@sun.com>
	<BEB67402-7AFE-4BE1-A59C-050823AFC8E5@Sun.COM>
	<4977647D.5010503@sun.com> <4977E5BD.7000706@sun.com>
	<4978DB1E.30507@sun.com> <20090122225512.GP3652@webber.adilger.int>
	<537C6C0940C6C143AA46A88946B854170D40BE5B@ORNLEXCHANGE.ornl.gov>
	<20090126195728.GH3652@webber.adilger.int>
Message-ID: <4981CD1B.5020407@ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On Jan 23, 2009  12:39 -0500, Shipman, Galen M. wrote:
>   
>> Looks like HPSS will support EA in 7.1.2.0, June 2009
>> I have asked Vicky here at ORNL to dig a bit into what the EA features will
>> look like.  Do we have a set of requirements for EAs for HSM integration?
>>     
>
> As yet we don't have a hard requirement for EAs in HSM.  We would ideally
> keep the LOV EA for the file layout in the HSM, so that the file gets
> (approximately) the same layout when it is restored.  This is only really
> needed for files that were not allocated using the default layout, and
> we might consider saving e.g. "stripe over all OSTs" instead of "stripe
> over N OSTs" so that if the number of OSTs increases from when the file
> was archived until it is restored the new file gets the full performance.
>   


Also, if for some reason the number of OFTs decreases, the stripe all 
could just use the new available value.


>> I got a paper from CEA that indicated HPSS was going to (or may have
>> already) implemented EA support, but it isn't at all clear if that
>> version of software would be available at all sites, since AFAIK it
>> is relatively new.
>>
>> Cheers, Andreas
>>     


This version of the HPSS software with the EA support (now called UDA 
for User Defined Attributes) will be available in the baseline HPSS 
code, available to all sites.   Target availability date is summer 2009.


Vicky
