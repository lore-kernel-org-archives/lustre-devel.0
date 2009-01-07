From: Alex Zhuravlev <bzzz@sun.com>
Date: Wed, 07 Jan 2009 13:01:50 +0300
Subject: [Lustre-devel] global epochs v. dependencies
In-Reply-To: <20090106195958.GC13721@webber.adilger.int>
References: <01d001c96b5b$5a595650$0f0c02f0$@com>
	<20090106195958.GC13721@webber.adilger.int>
Message-ID: <20090107130150.2f7a9707@bzzz.home.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 06 Jan 2009 12:59:58 -0700
Andreas Dilger <adilger@sun.com> wrote:
> > <eeb>    if you make each MDS the proxy for the lustre clients
> > (like we do now with having the master MDS do the RPCs to the slave
> > MDSes) then you've limited the global oldest volatile epoch
> > calculation to just the servers 
> 
> This is exactly the kind of implementation that I hope we will end
> up with - we DON'T have to have every client involved in the epochs,
> only the servers and clients that are doing WBC (e.g. login nodes,
> proxy clients for a WAN, etc).  This set would be flexible hopefully,
> so that nodes like login nodes could temporarily start doing WBC
> operations under load, but flush their state and return to "dumb"
> clients when idle.

If i understood you right, you prefer to send all updates through one
server? while this has obvious benefits (like sanity checks, ability
to employ persistent redo, etc) I believe generic mechanism should be
able to send updates to target server directly. probably the best
example here would be SNS. depending on nature and source of updates,
we can choose either way.

let me remind that with dependency-based schema clients are "dumb" all
the time, then only thing they have to do is to tag updates with unique
id.

thanks, Alex
