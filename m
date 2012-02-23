From: Jack David <jd6589@gmail.com>
Date: Thu, 23 Feb 2012 15:13:01 +0530
Subject: [Lustre-devel] OSC-OST data path optimization
In-Reply-To: <CAJbRZyWpQCw6SLm5JV2a4cFAZeRo036rErf5xw+1-h99=4wR=Q@mail.gmail.com>
References: <CAJbRZyWjBFew3mHvJtzBbph3CoSCtbO115kx5RV=3fpYOZhs+g@mail.gmail.com>
	<805395AD-C226-49DD-BA9B-A86E553C5746@whamcloud.com>
	<CAJbRZyWpQCw6SLm5JV2a4cFAZeRo036rErf5xw+1-h99=4wR=Q@mail.gmail.com>
Message-ID: <CAJbRZyXPLVmgyHAu+W0cqZppSN2gZtwSutMw-we8xqc37yadqg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Feb 23, 2012 at 12:49 PM, Jack David <jd6589@gmail.com> wrote:
> On Wed, Feb 22, 2012 at 11:37 PM, Andreas Dilger <adilger@whamcloud.com> wrote:
>> On 2012-02-22, at 7:04, Jack David <jd6589@gmail.com> wrote:
>>> I am browsing through the lustre code and I want to learn if
>>> OSC-to-OST (being on the same node) communication can be optimized. I
>>> am not sure if the lustre discussion is the correct group for this, so
>>> I thought of sending the emails to you guys.
>>
>> The best place for technical discussions is one lustre-devel at lists.lustre.org. ?I've CC'd the list on this reply.
>>
>
> Thanks for forwarding it to correct discussion group.
>
>>> I am focusing on the WRITE scenario as of now (i.e. lustre client is
>>> writing a file on server). On the OSC side, the descriptor ("desc") is
>>> filled in osc_brw_prep_request() function, and the preparation for
>>> sending the OST_WRITE request to server (i.e. OST) is carried out (I
>>> am not familiar with Portal RPC and its mechanics so currently I am
>>> skipping the calls which actually prepares the request).
>>>
>>> On the OST side, upon receiving the OST_WRITE request, the
>>> ost_brw_write function will also start the preparation for the
>>> buffers. The function invoked is filter_preprw (and in turn
>>> filter_preprw_write) will actually find out the corresponding
>>> inode/dentry from the "fid" and prepare the pages in which incoming
>>> data can be filled.
>>>
>>> I noticed that while preparing the pages on OST, there is a check
>>> which makes sure that if peer_nid and local nid are same. Is it
>>> possible that OST/OSC can use this information and OSC will send the
>>> page information in the OST_WRITE request, and OST will put it into
>>> page_cache (I am not an expert in linux kernel and not sure if linux
>>> kernel allows, but idea is to share the pages instead of copying)?
>>
>> The difficulty is that the cache on the OSS also has its own pages, so either Lustre will need to do nasty things with the page cache for both the client address space and the server address space, or there has to be a memcpy() somewhere in the IO path.
>>
>> The best way to handle this would be to set up a special combined OSC-OST module that bypasses the RPC layer entirely, but this would be a lot of work to maintain.
>>
>> While we have thought about doing this for a long time, one important question is whether this is really a bottleneck. It would be easy to see this by running oprofile to see whether the memcpy() is ? consuming all of the CPU.
>>
>
> Thanks for the suggestion. I will carry out oprofile tests and see how
> much CPU memcpy consumes.
>
>> Note that in Lustre 2.2 there are multiple ptlrpcd threads that should allow doing the memcpy() on multiple cores.
>>
>> It might also be worthwhile to automatically disable data checksums for local OSC-OST bulk RPCs, since this can have a noticeable performance impact if both ends are on the same node.
>>
>
> I tried to look for the checksum in the code and found the
> "ksocknal_tunables.ksnd_enable_csum". Is this correct parameter to
> enable/disable the checksum? I noticed that it is enabled by default.
> I tried to disable it in the transmit path (in ksocknal_transmit()).
> But what I noticed is, ksocknal_trasmit only come into picture when
> OSC and OST are setup on different nodes. If they both are on the same
> node, this path is not taken (and may be loopback code comes into
> picture lnet/lnet.lo.c - not sure though). Will checksum be enabled
> for the loopback path?
>
>

Okay, while search for checksum code, I missed the checksum
calculation done on OSC/OST bulk data if cli->cl_checksum bit it set.
This was actually caught up during oprofile report. Following is the
top entries in the report.

samples  %        app name                 symbol name
2251      7.9462  vmlinux                  copy_user_generic_string
2059      7.2684  ost.ko                   ost_checksum_bulk
1759      6.2094  osc.ko                   osc_checksum_bulk
1104      3.8972  vmlinux                  hpet_readl
1007      3.5548  vmlinux                  memcpy_c
648       2.2875  vmlinux                  mwait_idle
474       1.6733  vmlinux                  native_read_tsc
444       1.5674  bash                     /bin/bash
353       1.2461  lvfs.ko                  lprocfs_counter_add
234       0.8260  vmlinux                  page_fault
215       0.7590  vmlinux                  kmem_cache_alloc
215       0.7590  vmlinux                  list_del


Thanks
J



-- 
J
