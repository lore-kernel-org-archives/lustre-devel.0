From: Nikita Danilov <nikita.danilov@clusterstor.com>
Date: Wed, 2 Dec 2009 23:58:39 +0300
Subject: [Lustre-devel] Fwd: Disk rebuild
In-Reply-To: <E9666E71-8BE9-400D-9EA4-445011BB8961@sun.com>
References: <8acda98c0912010700r684bfcf6h94ec347cd6190990@mail.gmail.com>
	<20091201235754.GC4508@clouds>
	<8acda98c0912020613l4cee1a43s3be7ec4f52383304@mail.gmail.com>
	<E9666E71-8BE9-400D-9EA4-445011BB8961@sun.com>
Message-ID: <8acda98c0912021258j140748b1wb2cdb0d2036a864a@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

2009/12/2 Andreas Dilger <adilger@sun.com>:
> Hi Nikita!

Hello Andreas!

>
> On 2009-12-02, at 07:13, Nikita Danilov wrote:
>>>
>>> On Tue, Dec 01, 2009 at 06:00:39PM +0300, Nikita Danilov wrote:
>>>>
>>>> what is the status of this? Is ext3 guided resync code (RHEL 5 version
>>>> was posted on lkml in October) used by Lustre?
>>>
>>> This is covered by bug 19932.
>>
>> The last (43rd) comment there is rather intriguing. Can you elaborate
>> on why guided resync cannot work with the Lustre IO stack?
>
>
> The problem lies in the way that obdfilter submits IO. ?Since it is not
> using the normal buffer cache to track "data=ordered" (or in the case of
> this patch "data=declared") mode the bio_submit() will likely start
> modifying the MD device before the corresponding declare blocks are
> committed to the journal.

Thank you for the detailed explanation, data-path completely escaped
my mind. Still, on the mdt side, osd goes through the normal VFS paths
and data=declared should work, right?

[...]

>
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
>

Thank you,
Nikita.
