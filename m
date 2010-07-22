From: Nikita Danilov <nikita.danilov@clusterstor.com>
Date: Thu, 22 Jul 2010 19:49:29 +0400
Subject: [Lustre-devel] clio layer & portability
In-Reply-To: <AANLkTilh5j1mgazvNUyb-gvMhfcYcOYlWfo1DHSSULpc@mail.gmail.com>
References: <201007221510.o6MFARem014801@hedwig.cmf.nrl.navy.mil>
	<AANLkTilh5j1mgazvNUyb-gvMhfcYcOYlWfo1DHSSULpc@mail.gmail.com>
Message-ID: <AANLkTinIWyblQGkU_qGWKpT0b-xXAyyybVvwnF0e-2Ue@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Sorry to follow up on myself...

On 22 July 2010 19:43, Nikita Danilov <nikita.danilov@clusterstor.com> wrote:
> Hello,

[...]

>
> I think any modern UNIX version does this. BSDs and Solaris have
> PUT_PAGE() vnop. When I was porting Lustre to OS X (Panther times)
> there used to be two ways to do this: at the UBC/VFS level and at the
> UPL/Mach level, I am not sure how things work nowadays.
>

I just checked xnu-1504.7.4/bsd/vm/vnode_pageout(). It seems to call
VNOP_PAGEOUT(), which looks quite similar to Linux ->writepage(). It
is possible for a Lustre client port to override this VNOP?

Thank you,
Nikita.

>
>>
>> Obviously these aren't new issues. ?For the first release of the MacOS port,
>> I didn't use clio at all. ?But now it's coming up and I'm wondering ...
>> since Lustre is now being ported to other OSes, what did everyone else
>> do about these issues?
>>
>> --Ken
>
> Thank you,
> Nikita.
>
>>
>
