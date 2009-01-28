From: Vicky White <vyw@ornl.gov>
Date: Wed, 28 Jan 2009 15:30:37 -0500
Subject: [Lustre-devel] SAM-QFS, ADM, and Lustre HSM
In-Reply-To: <9365C284-E805-46B6-95B2-226C1E2ED112@Sun.COM>
References: <D262D095-D17F-4119-B908-FBE502201835@Sun.COM>
	<49480788.7080306@sun.com>
	<FCBC9AEA-C61C-4EEA-847B-FE283D19A7BF@Sun.COM>
	<05e901c95fba$f7688df0$e639a9d0$@com> <49481EEF.2010802@sun.com>
	<EB7E4462-1CFF-4CCD-A38F-AE4D89108B59@Sun.COM>
	<3DF0F4AF-F4D6-476E-98F7-CD912C49FC18@Sun.COM>
	<2734A30F-2C76-4725-9F3A-29AD4245B7E8@Sun.COM>
	<496FCA67.6000500@sun.com>
	<48D329C0-242E-4A5A-94C1-DF493BB25C2F@Sun.COM>
	<496FE8D4.2090908@sun.com>
	<BEB67402-7AFE-4BE1-A59C-050823AFC8E5@Sun.COM>
	<4977647D.5010503@sun.com>
	<4977E5BD.7000706@sun.com> <4978DB1E.30507@sun.com>
	<9365C284-E805-46B6-95B2-226C1E2ED112@Sun.COM>
Message-ID: <4980C06D.3000309@ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Comments on several messages; I am slowly catching up.


> I do see work to switch the HPSS APIs to ftp or pftp. If this is  
> already supported by HPSS, then, yes, no changes are required.
>   

HPSS supports ftp and pftp.   However, this seems to be a moot point as 
Thomas points out that CEA is using the HPSS client API library for 
their copy tool:


> At CEA, we are using our own copytool that directly uses HPSS API. 
> This already exists and is in production for years.
> I think there will be few modifications to adapt it to Lustre-HSM purpose
> (basically, add fid <-> HSM id mapping and backup of attributes, path, 
> stripe...)


>   There is also "htar" which is a tar-like interface to
> HPSS, but I don't think that was anyone's intention to use.


htar is a well proven and valuable tool for aggregation to HPSS.   It is 
widely used at HPSS sites as a stand-alone utility and has been 
incorporated into other interfaces. 


> Looks like HPSS will support EA in 7.1.2.0, June 2009
> I have asked Vicky here at ORNL to dig a bit into what the EA features will look like. 
>   

The last draft of this design I saw was from November.    Work on this 
is picking up right now and has been bumped to a high priority, due for 
release this June, as Galen says.   I am trying to find out if there is 
a later design and how much about it I can share.


> Do we have a set of requirements for EAs for HSM integration?

I never saw an answer to Galen's question above; did I miss it?  Now is 
the time to speak up if we need to influence the design of the HPSS EAs.


>   > We would need to decide whether the HPSS implementation can/should
>   > handle aggregating multiple small files into a single archive object.
>   > I think that is useful, and this is one reason I advocate being able
>   > to pass multiple files at once from the coordinator to the agent.
> Last I knew, they still don't build a container for small files. They 
> write
> a tape mark between each file. This means they are start/stopping the
> tape for small files. A lot of sites use SRB which builds a tar container.

As of HPSS 7.1, we build a container for small files before copying them 
to tape.  It's called Tape Aggregation and we call the container an 
aggregate.   Tape Aggregation is controlled via the HPSS migration 
policy, where the sysadm can configure whether or not to aggregate, the 
minimum and maximum files to place in each aggregate, and the maximum 
size of each aggregate.


Vicky
