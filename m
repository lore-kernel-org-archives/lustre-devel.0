From: Alexey Lyashkov <alexey.lyashkov@gmail.com>
Date: Mon, 4 Jun 2018 06:59:45 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: delete the filesystem
 from the tree.
In-Reply-To: <87h8mjp5o0.fsf@notabene.neil.brown.name>
References: <20180601091133.GA27521@kroah.com>
 <20180601114151.GA25225@infradead.org>
 <E5BF8501-35EB-4DDF-ADBE-6016CF31A502@dilger.ca>
 <29ACF5A8-7608-46BB-8191-E3FEB77D0F24@cray.com>
 <87h8mmrt6b.fsf@notabene.neil.brown.name>
 <58123CDD-8424-4E1D-A11F-0F899970A49B@intel.com>
 <87h8mjp5o0.fsf@notabene.neil.brown.name>
Message-ID: <FE290581-D17D-4CEC-9AE2-B79DCBBD0823@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Dilger, Andreas" <andreas.dilger@intel.com>, Andreas Dilger <adilger@dilger.ca>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, "selinux@tycho.nsa.gov" <selinux@tycho.nsa.gov>, fsdevel <linux-fsdevel@vger.kernel.org>, lustre-devel <lustre-devel@lists.lustre.org>


> 4 ???? 2018 ?., ? 6:54, NeilBrown <neilb@suse.com> ???????(?):
> 
> On Sun, Jun 03 2018, Dilger, Andreas wrote:
> 
>> On Jun 1, 2018, at 17:19, NeilBrown <neilb@suse.com> wrote:
>>> 
>>> On Fri, Jun 01 2018, Doug Oucharek wrote:
>>> 
>>>> Would it makes sense to land LNet and LNDs on their own first?  Get
>>>> the networking house in order first before layering on the file
>>>> system?
>>> 
>>> I'd like to turn that question on it's head:
>>> Do we need LNet and LNDs?  What value do they provide?
>>> (this is a genuine question, not being sarcastic).
>>> 
>>> It is a while since I tried to understand LNet, and then it was a
>>> fairly superficial look, but I think it is an abstraction layer
>>> that provides packet-based send/receive with some numa-awareness
>>> and routing functionality.  It sits over sockets (TCP) and IB and
>>> provides a uniform interface.
>> 
>> LNet is originally based on a high-performance networking stack called
>> Portals (v3, http://www.cs.sandia.gov/Portals/), with additions for LNet
>> routing to allow cross-network bridging.
>> 
>> A critical part of LNet is that it is for RDMA and not packet-based
>> messages.  Everything in Lustre is structured around RDMA.  Of course,
>> RDMA is not possible with TCP

To be clear. Soft IB (aka Soft RoCE) driver is part of OFED stack from 4.8(or 4.9).
So RDMA API now is possible with TCP networks.


Alex
