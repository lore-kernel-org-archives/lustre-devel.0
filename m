From: Cory Spitz <spitzcor@cray.com>
Date: Tue, 21 May 2013 19:24:29 +0000
Subject: [Lustre-devel] lustre kernel configuration
In-Reply-To: <519BC55A.4040903@lanl.gov>
Message-ID: <CDC13365.C781%spitzcor@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Kernel configs are kept in the tree.  You can find master's set at
http://git.whamcloud.com/?p=fs/lustre-release.git;a=tree;f=lustre/kernel_pa
tches/kernel_configs;h=88ca1484fa6597a7d786f3f09f03612f6d039db2;hb=HEAD

-Cory

On 5/21/13 2:04 PM, "Ron Croonenberg" <ronc@lanl.gov> wrote:

>Hi Chris,
>
>thanks for the link.  What I was looking for was the Linux kernel config
>but couldn't find any documentation foor (would have been nice to find
>the ones that are actuallu used in the binaries).
>
>Basically what I did is take my RHEL6 config and configured the kernel
>wit and compiling that seemed to work. (I did compile the rpms, just a
>regular make. That seemed to work for 1.8.7.
>I haven't installed anything yet., so we'll see on that part.
>
>thanks,
>
>Ron
>
>On 05/21/2013 12:16 PM, Christopher J. Morrone wrote:
>> If you use the zfs osd for your servers, there is no need to modify your
>> Linux kernel.  That is probably a much easier way to get started with
>> Lustre development.
>>
>> If you are set on using the ldiskfs osd, Intel has some instructions on
>> their wiki here:
>>
>>     https://wiki.hpdd.intel.com/display/PUB/Building+Lustre+from+Source
>>
>> Chris
>>
>> On 05/21/2013 07:11 AM, Ron Croonenberg wrote:
>>> hello,
>>>
>>> I am looking into some Lustre development but want to build everything
>>> from scratch. I looked around to see how the linux kernel is configured
>>> but don't seem to find anything.
>>>
>>> any ideas?
>>>
>>> thanks,
>>>
>>> Ron
>>> _______________________________________________
>>> Lustre-devel mailing list
>>> Lustre-devel at lists.lustre.org
>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>
>_______________________________________________
>Lustre-devel mailing list
>Lustre-devel at lists.lustre.org
>http://lists.lustre.org/mailman/listinfo/lustre-devel
