From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 9 Nov 2011 15:00:37 -0700
Subject: [Lustre-devel] [wc-discuss] Lustre code style Git commit hooks
In-Reply-To: <alpine.LFD.2.02.1111091918270.401@casper.infradead.org>
References: <E524F377-9B95-4736-92FF-22C711DD9EE8@whamcloud.com>
	<20111103222831.GB19258@llnl.gov>
	<8FB8F9D4-A179-490D-AE9F-61C731FD98AA@whamcloud.com>
	<1320443263.7466.26.camel@brian-laptop>
	<alpine.LFD.2.02.1111091624400.14374@casper.infradead.org>
	<855EC42A-3184-49A5-AC6E-9C5012166319@whamcloud.com>
	<alpine.LFD.2.02.1111091918270.401@casper.infradead.org>
Message-ID: <ABD9E0C9-58A5-43D6-B382-6E5EE7FE6688@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-11-09, at 12:23 PM, James Simmons wrote:
>> An earlier version of the commit-msg hook used "git hash-object -t commit" and it caused an empty Change-Id string for older versions of Git. The "-t commit" option was removed from the latest version and solved the problem for the people that used it.
> 
> Yes your right. I updated the hooks and it works now. I also had to learn 
> you need a subsystem: field for commits now. Info about the subsystem 
> field is not the wiki.

Hmm, which wiki page are you referring to?  The "Using Gerrit" page has had
the "component:" tag since june, long before I sent out the email,
and it was in the original email as well:

> The commit-msg hook verifies the format of the commit message itself,
> so that it contains a Jira ticket number, a "subsystem:" field, a
> commit body, and a Signed-off-by: line.  If no Gerrit "Change-Id:"
> line is present it will automatically add this as well.  The new
> "subsystem:" field is similar to those used for kernel commit messages
> all have, so that it is easier to decide what part of the code a patch
> affects.

If it is missing on some other wiki page, I'd like to correct it.

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
