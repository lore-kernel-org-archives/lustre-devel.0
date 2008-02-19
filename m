From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 19 Feb 2008 18:42:03 +0300
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <05e801c8730c$87cbc7a0$0281a8c0@ebpc>
References: <47BAA607.1000600@sun.com> <05e801c8730c$87cbc7a0$0281a8c0@ebpc>
Message-ID: <47BAF8CB.7090903@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

well, this was one of the reasons I asked lustre-devel@ for inputs.
what else we do consider important to store in inode.

probably we should list all existing and planned EAs and rank them.

also, I've got to think that for some cases we don't need to load
LOV EA. for example, for getattr in case of SOM (size/blocks are
cached on MDS). or for revalidation when client already has LOV EA.

thanks, Alex

Eric Barton wrote:
> Rather than discussing this one EA at a time, should we not
> consider any other EAs (e.g. being considered in current 
> architecture work) that might contend for space in the inode?
> 
>> -----Original Message-----
>> From: lustre-devel-bounces at lists.lustre.org 
>> [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of 
>> Alex Zhuravlev
>> Sent: 19 February 2008 9:49 AM
>> To: lustre-devel at lists.lustre.org
>> Subject: [Lustre-devel] storing SOM epoch in EA
>>
>> Good day,
>>
>> some time ago we discussed that it would be very helpful to
>> store epoch in inode on mds. the perfect solution could be
>> to store epoch in old inode body, but there is no much space
>> for this in the body and with DMU we'll have this problem
>> again.
>>
>> given the minimal inode size we use on MDS is 512 bytes, we
>> can store upto 13 stripes in the body. larger EAs go to a
>> dedicated block. if we add 8 byte epoch, then we can store
>> upto 12 stripes in the body. so, epoch stored in EA affects
>> only files with exactly 13 stripes. files with different
>> stripes are unaffected at all.
>>
>> couple lesser concerns are:
>> 1) cpu usage
>> 2) epoch on old filesystem with insufficient inode space
>>
>> any objections to use EA to store SOM epoch?
>>
>> thanks, Alex
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
