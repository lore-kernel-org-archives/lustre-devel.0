From: W. Zhang <wszhang159@gmail.com>
Date: Wed, 23 Nov 2016 17:05:25 +0800
Subject: [lustre-devel] Failed to build a Lustre Storage Client on
 OpenVZ Kernel ! Is this a bug?
In-Reply-To: <CAAXb9Mvz-i0iCFsVJQ-Jv=F8eQHsxqLWfbK1ZHs3dTJSoMUAXw@mail.gmail.com>
References: <CAAXb9Ms-4+aDuS10g3Y4qbPiJyaP74Fk-Gh+4=7KaTLacvAZRA@mail.gmail.com>
	<alpine.LFD.2.20.1611070202430.21293@casper.infradead.org>
	<CAAXb9Mv81o3RywPWhspEOyrR0QWvtgQHQLJPPyNvi77n-c-M-g@mail.gmail.com>
	<CAAXb9Mvz-i0iCFsVJQ-Jv=F8eQHsxqLWfbK1ZHs3dTJSoMUAXw@mail.gmail.com>
Message-ID: <CAAXb9MsyiG0Suwx2eWGqWZHZt_H6R60FWo8v-PxjR_nWfN0NyQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dear James and All,

Zipped file "*config.log*" is attached, file in the former is too big
(beyond the limit of 150 KB).

Thanks very much and sorry for the redundancy!

Best Wishes!




2016-11-23 16:46 GMT+08:00 W. Zhang <wszhang159@gmail.com>:

> Sorry to All!
>
> I prepared the file '*config.log*' but forgot to attach it in the former!
>  (T-T)
>
> Here it is!
>
> Best Wishes!
>
>
>
>
>
> 2016-11-23 16:35 GMT+08:00 W. Zhang <wszhang159@gmail.com>:
>
>> Dear James and All,
>>
>> Attached is the file 'config.log'!
>>
>> Thanks very much for previous attention!
>>
>> Best Wishes!
>>
>> 2016-11-07 10:03 GMT+08:00 James Simmons <jsimmons@infradead.org>:
>>
>>>
>>> > Hello,
>>> >
>>> > I'm trying to build a Lustre client on OpenVZ kernel (version:
>>> 042stab120.5, based on RHEL 6.8 kernel
>>> > 2.6.32-642.6.1.el6), and some bugs occured:
>>> >
>>> > (1) When build version v2_8_59_0 in git tag repo of Lustre, I
>>> encountered the following errors:
>>> > "
>>> > LD [M] /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/fld/
>>> fld.o
>>> > CC [M] /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/lloop.o
>>> > In file included from /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/lloop.c:109:
>>> > /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/llite_internal.h:1469: error: conflicting types for
>>> > 'iov_iter_iovec'
>>> > include/linux/fs.h:765: note: previous definition of 'iov_iter_iovec'
>>> was here
>>> > /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/llite_internal.h: In function 'iov_iter_iovec':
>>> > /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/llite_internal.h:1472: error: 'const struct
>>> > iov_iter' has no member named 'iov'
>>> > /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/llite_internal.h:1473: error: 'const struct
>>> > iov_iter' has no member named 'iov'
>>> > cc1: warnings being treated as errors
>>> > /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/llite_internal.h:1473: error: type defaults to 'int'
>>> > in declaration of '_min2'
>>> > ...
>>> > "
>>> >
>>> > (2) When build old version v2_8_50_0 in git tag repo of Lustre, the
>>> following errors display:
>>> > "
>>> > CC [M] /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/vvp_lock.o
>>> > CC [M] /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/vvp_io.o
>>> > /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/vvp_io.c: In function 'vvp_mmap_locks':
>>> > /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/vvp_io.c:423: error: 'struct iov_iter' has no member
>>> > named 'iov'
>>> > /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/vvp_io.c: In function 'vvp_io_advance':
>>> > /opt/src/lustre_testvz/lustre_new/lustre-r161012/lustre/llit
>>> e/vvp_io.c:514: error: 'struct iov_iter' has no member
>>> > named 'iov'
>>> > ...
>>> > "
>>> >
>>> > Files with full error context are attached.
>>> >
>>> > So, How can I fix the problem? Is this a bug which need to be fixed?
>>>
>>> Can you post your config.log.
>>>
>>>
>>> > Thanks! Any suggestion is appreciated!
>>> >
>>> > Best Wishes!
>>> >
>>> >
>>>
>>
>>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161123/b3b58d1a/attachment-0001.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: config.log.zip
Type: application/zip
Size: 33503 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161123/b3b58d1a/attachment-0001.zip>
