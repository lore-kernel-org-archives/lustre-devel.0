From: James Simmons <jsimmons@infradead.org>
Date: Mon, 26 Nov 2018 03:47:26 +0000 (GMT)
Subject: [lustre-devel] [PATCH 0/9] Assorted lustre patches - mostly
 from OpenSFS
In-Reply-To: <154295730810.2850.961218355189474016.stgit@noble>
References: <154295730810.2850.961218355189474016.stgit@noble>
Message-ID: <alpine.LFD.2.21.1811260344030.32255@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This is a miscellaneous set of patches for lustre-in-linux.
> Apart from the first, they are (bases on) patches from OpenSFS lustre.
> I've been trawling through OpenSFS looking for patches that aren't
> in linux-lustre.  Most of what I find are only relevant on the
> server, but these seem to be appropriate for the client.
> In most cases, I don't really know what is going on, so they
> might be inappropriate for the client.  I'm hoping that more
> knowledgeable people can put be straight.
> 
> This are just the first few - I think there are quite a few more
> (before we get to e.g. pfl which has been attempted yet).  If
> I've got these mostly right, I'll continue looking through
> the rest of my list.

To let you know I have ported the PFL patches for the linux client.
I'm currently doing testing to make sure it works correctly. Need
to work out some bugs but the major porting is done :-)
