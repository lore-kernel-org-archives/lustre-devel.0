From: Jinshan Xiong <jinshan.xiong@whamcloud.com>
Date: Wed, 8 Jun 2011 13:09:36 -0700
Subject: [Lustre-devel] discontiguous kiov pages
In-Reply-To: <4DEF9E8F.6070202@cray.com>
References: <4DE6F67B.6040207@cray.com> <002c01cc2127$ac5b7da0$051278e0$@com>
	<B91FC92C-00B4-4C0B-A0D1-DA2E6912697D@whamcloud.com>
	<4DEF9E8F.6070202@cray.com>
Message-ID: <242A2918-D133-4A37-A3FF-B49B34CACA08@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jun 8, 2011, at 9:08 AM, Nic Henke wrote:

> On 06/07/2011 06:57 PM, Oleg Drokin wrote:
>> Hello!
>> 
> 
>>>> It used to be that only the first and last page in an IOV were allowed
>>>> to be of a offset + length<  PAGE_SIZE.
>>> Quite correct.  LNDs have relied on this for years now.
>>> A change like this should not have occurred without discussion
>>> about the wider impact.
>> 
>> Actually now that we found what's happening, I think the issue is a bit less clear-cut.
>> 
>> What happens here is the client is submitting two niobufs that are not contiguous.
>> As such I see no reason why they need to be contiguous in VM too. Sure the 1.8 way of handling
>> this situation was to send separate RPCs, but I think even if two RDMA descriptors need to be
>> made, we still save plenty of overhead to justify this.
>> 
>> (basically we send three niobufs in this case: file pages 0-1, 40-47 (the 47th one is partial) and 49 (full) ).
> 
> Oleg - it isn't clear to me what fix you are suggesting here. Are you 
> saying LNet/LNDs should handle this situation (partial internal page) 
> under the covers by setting up multiple RDMA on their own? This sounds 
> like an LND API change, requiring a fix and validation for every LND. I 
> *think* we might end up violating LNet layering here by having to adjust 
> internal LNet structures from the LND to make sure the 2nd and 
> subsequent RDMA landed at the correct spot in the MD, etc.

Please refer to LU-394 for detail description of this problem. For those who cannot access our jira system, I'm going to summarize it here.

The problem is as follows:
0. First, the app wrote a partial page A at the end of file, and it had enough grant on client side, so page A was cached;
1. app sought forward and wrote another page B which exceeded the quota limit, so it has to be written in sync mode(see vvp_io_commit_write);
2. in current implementation of CLIO, for performance consideration, writing page B will include as many cached pages as possible to compose an RPC, this includes page A;

So here comes the problem. The file size can only be extended until writing of page B succeed, otherwise, the file size is wrong in case writing of B fails. This causes ap_refresh_count() to page A returned oap_count less than CFS_PAGE_SIZE. This is why LND saw uncontiguous pages.

Fixing this issue is easy, we only write the sync page in a standalone RPC(not combine with cached pages). This is not a big issue, since it occurs only when quota runs out.

> 
> At least for our network, and I'd venture a guess for others, there is 
> no way to handle the partial page other than multiple RDMA at the LND 
> layer. When mapping these pages for RDMA, the internal hole can't be 
> handled as we just map a set of physical pages for the HW to read 
> from/write into with a single (address,length) vector. The internal hole 
> would be ignored and would end up corrupting data as we overwrite the hole.

Can't aglee more. Having multiple RDMA descriptors will make LND more complex.

What if we transferred the whole page anyway? This is okay because page offset and length will tell server which part of data is really useful. It will waste some bandwidth, but it's far better than issuing one more RPC.

Thanks,
Jinshan

> 
> Cheers,
> Nic
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110608/f788ae77/attachment.htm>
