From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Thu, 25 Mar 2010 12:26:30 -0400
Subject: [Lustre-devel] readdir for striped dir
In-Reply-To: <CDDB8DAF-F32B-44B6-863C-FF48A4E90BA5@sun.com>
References: <4BA7F8B3.8050104@sun.com>
	<A3F904D6-6838-426D-BA21-333281606AC8@sun.com>
	<4BA8A60C.4000504@sun.com>
	<8acda98c1003230915n3e75ac05pe8095bb910c5153b@mail.gmail.com>
	<AB4A89B7-B642-42D2-A5B4-6A5CDF5AAEC2@sun.com>
	<8acda98c1003231214i1771bd0q5eae1097cc4daedf@mail.gmail.com>
	<CDDB8DAF-F32B-44B6-863C-FF48A4E90BA5@sun.com>
Message-ID: <CD9F5176-C004-4D5C-B7D7-E6DDE586269A@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Mar 24, 2010, at 6:23 PM, Andreas Dilger wrote:
> In SUSv2 I didn't see any mention of entry ordering, per se, though  
> telldir() and seekdir() should presumably be repeatable for NFS re- 
> export, which implies that the user-visible ordering can't change  
> randomly between invocations, and it shouldn't change between clients  
> or clustered NFS export would fail.

We just need to remember starting MDS in the cookie and then the cookie
would be 100% repeatable. (or derive that in some other 100% repeatable
client-neutral way, but without having all clients to always choose the
same order for new readdirs of the same dir of course)

We need to do it anyway so that we don't end up returning some entries
we already returned in the past in clustered NFS reexport environment.

Bye,
    Oelg
