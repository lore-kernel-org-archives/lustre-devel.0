From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Nov 2011 19:14:23 +0000 (GMT)
Subject: [Lustre-devel] [wc-discuss] Lustre code style Git commit hooks
In-Reply-To: <20111114181024.GJ9136@llnl.gov>
References: <E524F377-9B95-4736-92FF-22C711DD9EE8@whamcloud.com>
	<20111103222831.GB19258@llnl.gov>
	<8FB8F9D4-A179-490D-AE9F-61C731FD98AA@whamcloud.com>
	<1320443263.7466.26.camel@brian-laptop>
	<alpine.LFD.2.02.1111091624400.14374@casper.infradead.org>
	<855EC42A-3184-49A5-AC6E-9C5012166319@whamcloud.com>
	<alpine.LFD.2.02.1111091918270.401@casper.infradead.org>
	<ABD9E0C9-58A5-43D6-B382-6E5EE7FE6688@whamcloud.com>
	<alpine.LFD.2.02.1111141607030.3705@casper.infradead.org>
	<20111114181024.GJ9136@llnl.gov>
Message-ID: <alpine.LFD.2.02.1111141913160.19436@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > > >> An earlier version of the commit-msg hook used "git hash-object -t commit" and it caused an empty Change-Id string for older versions of Git. The "-t commit" option was removed from the latest version and solved the problem for the people that used it.
> > > > 
> > > > Yes your right. I updated the hooks and it works now. I also had to learn 
> > > > you need a subsystem: field for commits now. Info about the subsystem 
> > > > field is not the wiki.
> > > 
> > > Hmm, which wiki page are you referring to?  The "Using Gerrit" page has had
> > > the "component:" tag since june, long before I sent out the email,
> > > and it was in the original email as well:
> > 
> > http://wiki.whamcloud.com/display/PUB/Using+Gerrit
> > 
> > Looking at the page I do see the "component:" tag, but its because I 
> > looked for it. It needs to be more clear what is required to push a 
> > patch. Just a outsider's view.
> 
> Would a more detailed explanation of each "part" of the commit message
> help? For example, under the sample commit message:
> 
>  * LU-000: Issue number referencing an open issue at jira.whamcloud.com
> 
>  * component: The component(s) affected by this patch (i.e. osd-ldiskfs,
>               lnet, etc.)
> 
>  * Short Description: ...
> 
>  * etc...
> 
> Looking at the wiki page referenced above, it's a little hard to
> distinguish each section from one another. They all seem to blend into a
> single wall of text, IMO. Splitting them up into separate pages, or
> simply using a better color scheme to distinguish the sections apart,
> might help the page's readability as a whole.

Absolutely agree. I like the idea of a color scheme with the above format 
under the simple commit message.
