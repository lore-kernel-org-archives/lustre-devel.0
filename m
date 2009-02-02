From: Vicky White <vyw@ornl.gov>
Date: Mon, 02 Feb 2009 13:00:10 -0500
Subject: [Lustre-devel] Lustre HSM - some talking points.
In-Reply-To: <49872C9B.7060708@Sun.COM>
References: <3DF0F4AF-F4D6-476E-98F7-CD912C49FC18@Sun.COM>
	<2734A30F-2C76-4725-9F3A-29AD4245B7E8@Sun.COM>
	<496FCA67.6000500@sun.com>
	<48D329C0-242E-4A5A-94C1-DF493BB25C2F@Sun.COM>
	<496FE8D4.2090908@sun.com>
	<BEB67402-7AFE-4BE1-A59C-050823AFC8E5@Sun.COM>
	<4977647D.5010503@sun.com>
	<4977E5BD.7000706@sun.com> <4978DB1E.30507@sun.com>
	<497A144C.4000408@Sun.COM>
	<20090126193548.GF3652@webber.adilger.int> <497E35A3.3080603@sun.com>
	<DEB5E509-4641-40B6-86CA-972D885975D3@Sun.COM>
	<4983998D.1030601@sun.com>
	<8585251D-41D7-4B42-99F9-BDBFA2CF88C1@Sun.COM> <4987098F.402@Sun.COM>
	<367E32B4-A759-45AD-9D2C-48C051FE1D62@Sun.COM>
	<49872C9B.7060708@Sun.COM>
Message-ID: <498734AA.7010704@ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> 6.  No namepace.  No namespace.  Lustre pathnames can be stored as Extended
> Attributes.


I realize you are talking about SAMQFS, but do we want to keep the 
design consistent with what we do for hpss?

HPSS will support Extended Attributes in release 7.2, to be available 
September 2009, but it will be expensive to use these EAs for pathnames, 
though it can be done.   The current design is to specify EAs in XML, 
and for the most efficient storage of the EA in the database, the 
containing XML document needs to be 512 bytes or fewer so that it can be 
stored inline.  Larger XML objects will have to be stored externally as 
LOBs (large objects), which will make queries cost more.

So we need to think about what that cost will be when we are considering 
repositories with millions or billions of files.

Vicky
