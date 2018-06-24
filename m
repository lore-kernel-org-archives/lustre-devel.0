From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 09:26:11 +1000
Subject: [lustre-devel] [PATCH 24/24] lustre: discard TCD_MAX_TYPES
In-Reply-To: <alpine.LFD.2.21.1806242136380.28698@casper.infradead.org>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669094.10587.17019477478226952858.stgit@noble>
 <alpine.LFD.2.21.1806210237500.3886@casper.infradead.org>
 <87d0wkdaq0.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806242136380.28698@casper.infradead.org>
Message-ID: <87wounahrg.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 24 2018, James Simmons wrote:

>> As well as CFS_TCD_TYPE_CNT we have TCD_MAX_TYPES which has a larger
>> value but a similar meaning.  Discard it and just use
>> CFS_TCD_TYPE_CNT.
>> 
>> Two places relied on the fact that TCD_MAX_TYPES was larger and so
>> there would be NULLs at the end of the array.  Change
>> them to check the array size properly.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>> 
>> Thanks for testing James!
>> I found two problems.
>> 1/ I had
>> -       for (i = 0; cfs_trace_data[i] && i < CFS_TCD_TYPE_CNT; i++) {
>> instead of
>> +       for (i = 0; i < CFS_TCD_TYPE_CNT && cfs_trace_data[i]; i++) {
>> 
>> So it could dereference beyond the end of an array.  I don't this was
>> the problem.
>> 
>> 2/ I hadn't changed
>> -       for (i = 0; cfs_trace_data[i]; i++)                             \
>> to
>> +       for (i = 0; i < CFS_TCD_TYPE_CNT && cfs_trace_data[i]; i++)                             \
>> 
>> so if cfs_trace_data[4] was non NULL, bad things could happen.
>> I suspect this is what happened to you.
>> 
>> Thanks,
>> NeilBrown
>
> Much better :-)

Thanks for the confirmation!

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/499fd3ae/attachment.sig>
