From: Kit Westneat <kwestneat@datadirectnet.com>
Date: Fri, 07 Dec 2007 17:32:56 -0500
Subject: [Lustre-devel] Problems with make rpms
In-Reply-To: <1197003271.3550.26.camel@bear.shadowland>
References: <475863ED.30908@datadirectnet.com>
	<1197003271.3550.26.camel@bear.shadowland>
Message-ID: <4759CA18.6040406@datadirectnet.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Alex,

This is using 2.6.9-55.0.9.EL_lustre.1.6.3smp, on a Centos4 machine. I 
used the kernel-source rpm off of lustre.org, and then did make 
oldconfig and make, after changing the EXTRAVERSION to say smp instead 
of custom.

I've attached a capture of make rpms after doing a make clean. Let me 
know if there is anything else that would be interesting.

Thanks,
Kit

Alex Lyashkov wrote:
> Hello Kit,
>
> What kernel you used? is you build new kernel before build lustre?
> I'm ask about it, because some times ago in kernel series was added new
> patch for correctly create Module.symvers, if kernel sources not have
> this patch - this will be produce similar error.
>
> On Thu, 2007-12-06 at 16:04 -0500, Kit Westneat wrote:
>   
>> Hello,
>>
>> I'm trying to compile the b1_6 CVS branch, but I'm running into problems 
>> with 'make rpms'. 'make' works fine, but when I do 'make rpms' I get:
>>
>> make[4]: *** No rule to make target 
>> `/usr/src/redhat/BUILD/lustre-1.6.4.50/ldiskfs/Module.symvers', needed 
>> by `Module.symvers'.  Stop.
>>
>> Any thoughts?
>>
>> Thanks,
>> Kit
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at clusterfs.com
>> https://mail.clusterfs.com/mailman/listinfo/lustre-devel
>>     
>
>   

-------------- next part --------------
A non-text attachment was scrubbed...
Name: attachments.zip
Type: application/octet-stream
Size: 8473 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20071207/f02e987b/attachment.obj>
