From: James Simmons <jsimmons@infradead.org>
Date: Wed, 9 Nov 2011 19:23:13 +0000 (GMT)
Subject: [Lustre-devel] [wc-discuss] Lustre code style Git commit hooks
 and
In-Reply-To: <855EC42A-3184-49A5-AC6E-9C5012166319@whamcloud.com>
References: <E524F377-9B95-4736-92FF-22C711DD9EE8@whamcloud.com>
	<20111103222831.GB19258@llnl.gov>
	<8FB8F9D4-A179-490D-AE9F-61C731FD98AA@whamcloud.com>
	<1320443263.7466.26.camel@brian-laptop>
	<alpine.LFD.2.02.1111091624400.14374@casper.infradead.org>
	<855EC42A-3184-49A5-AC6E-9C5012166319@whamcloud.com>
Message-ID: <alpine.LFD.2.02.1111091918270.401@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > Speaking of I just attempted to push a patch and noticed that no Change-Id 
> > is being generated when I commit a new patch. This is with the default 
> > hooks that I copied form build directory.
> 
> Is this from the tip of the master branch?
> 
> An earlier version of the commit-msg hook used "git hash-object -t commit" and it caused an empty Change-Id string for older versions of Git. The "-t commit" option was removed from the latest version and solved the problem for the people that used it.

Yes your right. I updated the hooks and it works now. I also had to learn 
you need a subsystem: field for commits now. Info about the subsystem 
field is not the wiki.
