From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Fri, 17 Dec 2010 12:02:47 +0100
Subject: [Lustre-devel] Cannot easily build from master source anymore
In-Reply-To: <4D0A6024.7030403@llnl.gov>
References: <4CF6209A.6020401@cea.fr>	<alpine.LFD.2.00.1012011944370.22096@casper.infradead.org>	<DA432BB3-C1EC-433B-8936-923B98D7C446@oracle.com>	<4CF7ABC2.3000400@cea.fr>	<1292345822.4080.46.camel@brian-laptop>	<4D09F5C3.5060401@cea.fr>
	<4D0A6024.7030403@llnl.gov>
Message-ID: <4D0B4357.5020204@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Christopher J. Morrone a ?crit :
> I believe the reason it starts working at that commit is the annotated 
> tag that points to it.  Previous to that tag, Oracle was using simple 
> lightweight tags (which is git tag's default option).  With older 
> versions of git, "git describe" only stopped at annotated tags, not 
> lightweight tags.
> 
> So Oracle folks are probably just using newer versions of git than you.

Ok. That makes sense.
So I've update to 1.7.3

EPEL git package seems to old.


Thanks for your help.

-- 
Aurelien Degremont
CEA
