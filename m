From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Wed, 25 Mar 2009 12:48:03 -0700
Subject: [Lustre-devel] Start the MGS first?
Message-ID: <49CA8A73.9080103@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As of Lustre 1.6, servers can be started in any order (after the initial registration at first startup).  Internally, this required significant bending of our connection rules, and with a move toward ZFS becomes even more burdensome.  
So my question to the Lustre community is this: would anyone strenuously object to a startup ordering requirement that the MGS must be started before any other servers?  
This would probably be in the Lustre 3.0 timeframe.  It is also likely that we will have to divorce the MGS and MDT onto separate devices -- no more "combo" MDT/MGSes. 

> >  NR> I think the only reason to have a local config file is to be able to
> >  NR> start a server in the absence of the MGS.  How much effort do we want
> >  NR> to expend to be able to keep that ability?  I don't think it's a huge
> >  NR> burden to say "MGS must be started first".
