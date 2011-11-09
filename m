From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 9 Nov 2011 10:04:58 -0700
Subject: [Lustre-devel] [wc-discuss] Lustre code style Git commit hooks
	and
In-Reply-To: <alpine.LFD.2.02.1111091624400.14374@casper.infradead.org>
References: <E524F377-9B95-4736-92FF-22C711DD9EE8@whamcloud.com>
	<20111103222831.GB19258@llnl.gov>
	<8FB8F9D4-A179-490D-AE9F-61C731FD98AA@whamcloud.com>
	<1320443263.7466.26.camel@brian-laptop>
	<alpine.LFD.2.02.1111091624400.14374@casper.infradead.org>
Message-ID: <855EC42A-3184-49A5-AC6E-9C5012166319@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-11-09, at 9:27 AM, James Simmons <jsimmons@infradead.org> wrote:
> 
>>> 
> Speaking of I just attempted to push a patch and noticed that no Change-Id 
> is being generated when I commit a new patch. This is with the default 
> hooks that I copied form build directory.

Is this from the tip of the master branch?

An earlier version of the commit-msg hook used "git hash-object -t commit" and it caused an empty Change-Id string for older versions of Git. The "-t commit" option was removed from the latest version and solved the problem for the people that used it.

If updating to the latest version (or removing "-t commit") my fix this for you, please file a bug assigned to me and we can work it out. 

The contents of the .git directory are not under revision control, so it isn't possible to automatically update the commit hooks. At some point I'd like to update the hooks via "make", but was holding off until I have more confidence that issues like this related to different development environments are fixed. 

Thanks for the feedback. 

Cheers, Andreas
