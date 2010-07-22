From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Thu, 22 Jul 2010 21:27:06 +0300
Subject: [Lustre-devel] clio layer & portability
In-Reply-To: <AANLkTimly2Dz5LgHgCzF4qcHMdcfyZLl7s-EOXfwBLjl@mail.gmail.com>
References: <AANLkTilh5j1mgazvNUyb-gvMhfcYcOYlWfo1DHSSULpc@mail.gmail.com>
	<201007221626.o6MGQOPm016424@hedwig.cmf.nrl.navy.mil>
	<AANLkTimly2Dz5LgHgCzF4qcHMdcfyZLl7s-EOXfwBLjl@mail.gmail.com>
Message-ID: <F328DD91-FCAB-4182-8F89-904149A4A987@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jul 22, 2010, at 21:19, Nikita Danilov wrote:

>> If CLIO is more portable than I first thought, hey, great ... I've
>> spent a long time trying to trace through the CLIO layers and when I
>> find it quickly diving into Linux VM functions (sadly, things like the
>> VM code you did for the Panther port aren't available), that worries
>> and confuses me.  Since the Linux port is really my only example, it's
> 
> There used to be a text document, explaining CLIO internals in some
> detail, but I cannot find it anywhere. Perhaps somebody from Oracle
> can help.

that document should be exist here
http://wiki.lustre.org/index.php/Lustre_All-Hands_Meeting_12/08
but 
CLIO-TOI and CLIO documents have same data,
So looks bug on wiki.



--------------------------------------
Alexey Lyashkov
alexey.lyashkov at clusterstor.com
