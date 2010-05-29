From: Yuriy Umanets <yuriy.umanets@clusterstor.com>
Date: Sat, 29 May 2010 21:42:32 +0300
Subject: [Lustre-devel] a bug in "lfs find" command (patch attached)
In-Reply-To: <58780E32-8CA1-404C-9A37-FC14CD4CB002@oracle.com>
References: <AANLkTilhS3lwnn0q-V0VdoDfj6j1x_gt0vWNurpDJihB@mail.gmail.com>
	<58780E32-8CA1-404C-9A37-FC14CD4CB002@oracle.com>
Message-ID: <AANLkTikOxHWT4gcwC24upvdWJlVBqq3iUFZnKOOCPWeT@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

hi Andreas,

On Sat, May 29, 2010 at 7:22 PM, Andreas Dilger
<andreas.dilger@oracle.com>wrote:

> Yuriy, thanks for looking into this.  However, I think that the patch is
> not quite correct (though I haven't tested it yet). The issue is that the
> negation applies to each parameter individually, and not globally as you
> have changed it to be.
>
> That means that tests like:
>
> lfs find -mtime +1 ! -size 4
>
> Will now negate both the mtime and the size checks.  It seems that the
> correct thing to do is to store a per-test negation in the find params.
>

Yes, you are right. Lets make a bug in your bugzilla and work on this patch
there a bit.

>
> It is probably best to submit patches directly via bugzilla so that they
> don't get lost.
>
ok

>
> Please also make sure that there is an appropriate test in sanity.sh for
> the functionality being fixed.  There are already a number of lfs find
> tests, so new tests should be pit together.
>
> ok, got it.

> Cheers, Andreas
>
> Thanks!

>
> On 2010-05-29, at 3:56, Yuriy Umanets <yuriy.umanets@clusterstor.com>
> wrote:
>
>  hi Lustre people,
>>
>> One of our clients has found the bug in lfs find, which we have fixed.
>> Patch is attached. Issue is that find_value_cmp() and how it gets params are
>> buggy. Inversion made by inverting sign is completely wrong idea. Please see
>> the patch for details.
>>
>> Examples:
>>
>> Let's create some files and try to find them:
>>
>> [root at victim tests]# touch /mnt/lustre/a
>> [root at victim tests]# touch /mnt/lustre/b
>> [root at victim tests]# echo 1 > /mnt/lustre/c
>> [root at victim tests]# ls -la /mnt/lustre/
>> total 12
>> drwxr-xr-x  2 root root 4096 May 29 12:31 .
>> drwxr-xr-x 11 root root 4096 May  4 22:50 ..
>> -rw-r--r--  1 root root    0 May 29 12:31 a
>> -rw-r--r--  1 root root    0 May 29 12:31 b
>> -rw-r--r--  1 root root    2 May 29 12:31 c
>>
>> As you can see, there are 2 zero length files and one 2 bytes long file.
>>
>> Example of how it worked before fix:
>>
>> [root at victim tests]# ../utils/lfs find /mnt/lustre -s 0
>>
>> That is nothing found.
>>
>> [root at victim tests]# ../utils/lfs find /mnt/lustre -s 2
>>
>> Again nothing is found.
>>
>> [root at victim tests]# ../utils/lfs find /mnt/lustre ! -s 0
>>
>> Search for non zero length files also gives nothing.
>>
>> [root at victim tests]# ../utils/lfs find /mnt/lustre ! -s 1
>> /mnt/lustre/a
>> /mnt/lustre/b
>>
>> This finds two zero files but does not find one 2 bytes long file.
>>
>> After the fix:
>>
>> [root at victim tests]# ../utils/lfs find /mnt/lustre -s 0
>> /mnt/lustre/a
>> /mnt/lustre/b
>>
>> [root at victim tests]# ../utils/lfs find /mnt/lustre -s 2
>> /mnt/lustre/c
>>
>> [root at victim tests]# ../utils/lfs find /mnt/lustre ! -s 0
>> /mnt/lustre
>> /mnt/lustre/c
>>
>> [root at victim tests]# ../utils/lfs find /mnt/lustre ! -s 1
>> /mnt/lustre
>> /mnt/lustre/a
>> /mnt/lustre/b
>> /mnt/lustre/c
>>
>> [root at victim tests]# ../utils/lfs find /mnt/lustre -s +1
>> /mnt/lustre
>> /mnt/lustre/c
>>
>> This found all with size 1 and more.
>>
>> [root at victim tests]# ../utils/lfs find /mnt/lustre -s -1
>> /mnt/lustre/a
>> /mnt/lustre/b
>>
>> This found all smaller than 1 byte long.
>>
>> [root at victim tests]# ../utils/lfs find /mnt/lustre -s -0
>> /mnt/lustre/a
>> /mnt/lustre/b
>>
>> This found all that 0 or smaller :)
>>
>> Should I create bug in bugzilla or posting it to lustre-devel@ is ok?
>>
>> Thanks.
>> --
>> umka
>> <lfs-find-1.8.2.patch>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>
>


-- 
umka
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100529/23ff00ae/attachment.htm>
