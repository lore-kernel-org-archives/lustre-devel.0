From: Peter Bojanic <Peter.Bojanic@Sun.COM>
Date: Mon, 07 Jan 2008 00:04:21 -0400
Subject: [Lustre-devel] moving /proc to $MNT/.lustre
In-Reply-To: <47618E96.3080709@sun.com>
References: <47618E96.3080709@sun.com>
Message-ID: <F8F87424-C3EE-45E7-838E-95E1047F521D@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Nathan,

(Copying Lustre-devel)

On 2007-12-13, at 15:57 , Nathan Rutman wrote:

> Peter - I filed bug 14471 and Tom is running with it, but it's kind  
> of a big UI change and so I think someone In Authority should give  
> the go-ahead.  I think andreas and I are in agreement that it makes  
> sense.  The first step should be to do a nice DLD detailing  
> potential impact on all our tools, testing, debug etc.

Are you absolutely certain about this? This is going to break a ton of  
people's scripts.

This needs a few more nods from the architecture group -- I'd like to  
see at least eeb chime in.

By means of discussing it here, we're pretty much announcing the  
change to the Lustre community. But, if we proceed, you should also  
post a note to lustre-discuss for wider dissemination.

Thanks,
Bojanic
