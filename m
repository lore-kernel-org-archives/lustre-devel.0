From: Nicholas Henke <nic@cray.com>
Date: Wed, 25 Mar 2009 15:15:59 -0500
Subject: [Lustre-devel] Start the MGS first?
In-Reply-To: <49CA8A73.9080103@sun.com>
References: <49CA8A73.9080103@sun.com>
Message-ID: <49CA90FF.1070801@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathaniel Rutman wrote:
> As of Lustre 1.6, servers can be started in any order (after the initial 
> registration at first startup).  Internally, this required significant 
> bending of our connection rules, and with a move toward ZFS becomes even 
> more burdensome.  So my question to the Lustre community is this: would 
> anyone strenuously object to a startup ordering requirement that the MGS 
> must be started before any other servers?  This would probably be in the 
> Lustre 3.0 timeframe.  It is also likely that we will have to divorce 
> the MGS and MDT onto separate devices -- no more "combo" MDT/MGSes.
>> >  NR> I think the only reason to have a local config file is to be 
>> able to
>> >  NR> start a server in the absence of the MGS.  How much effort do 
>> we want
>> >  NR> to expend to be able to keep that ability?  I don't think it's 
>> a huge
>> >  NR> burden to say "MGS must be started first".
> 

This is virtually ensured today due to how the timeouts and ordering works.

1) It is a real PITA to script up different server start orders to deal with 
reformat and write_conf. It is easier to just script one correct way of doing 
this - KISS if you will.

2) At large scale, the timeout cascading on the OSTs (many OSTs per OSS) from a 
missing MGS requires it be started first.

3) With bug 14134 and --nomgs and --nosvc options for starting, it makes 
starting a combo MGS and MDS "correctly" much easier.

Nic
