From: Oleg Drokin <green@whamcloud.com>
Date: Tue, 7 Jun 2011 19:57:43 -0400
Subject: [Lustre-devel] discontiguous kiov pages
In-Reply-To: <002c01cc2127$ac5b7da0$051278e0$@com>
References: <4DE6F67B.6040207@cray.com> <002c01cc2127$ac5b7da0$051278e0$@com>
Message-ID: <B91FC92C-00B4-4C0B-A0D1-DA2E6912697D@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Jun 2, 2011, at 9:19 AM, Eric Barton wrote:
>> Our gnilnd is running into a hole in kiov list in Lustre 2.1:
>> 
>> LustreError: 17837:0:(gnilnd_cb.c:594:kgnilnd_setup_phys_buffer()) Can't make payload
>> contiguous in I/O VM:page 17, offset 0, nob 6350, kiov_offset 0 kiov_len 2254
>> LustreError: 17837:0:(gnilnd_cb.c:1751:kgnilnd_send()) unable to setup buffer: -22
>> 
>> Is it now legal for an internal IOV (or KIOV) page to have less than a full page size ?
>> 
>> It used to be that only the first and last page in an IOV were allowed
>> to be of a offset + length < PAGE_SIZE.
> Quite correct.  LNDs have relied on this for years now.
> A change like this should not have occurred without discussion
> about the wider impact.

Actually now that we found what's happening, I think the issue is a bit less clear-cut.

What happens here is the client is submitting two niobufs that are not contiguous.
As such I see no reason why they need to be contiguous in VM too. Sure the 1.8 way of handling
this situation was to send separate RPCs, but I think even if two RDMA descriptors need to be
made, we still save plenty of overhead to justify this.

(basically we send three niobufs in this case: file pages 0-1, 40-47 (the 47th one is partial) and 49 (full) ).

Bye,
    Oleg
