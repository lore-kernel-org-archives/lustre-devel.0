From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sat, 21 May 2016 05:51:09 +0000
Subject: [lustre-devel] [lustre-discuss] more on lustre striping
In-Reply-To: <1ef5a267-334c-be0d-13f4-c0fab917d1bf@iodoctors.com>
References: <1ef5a267-334c-be0d-13f4-c0fab917d1bf@iodoctors.com>
Message-ID: <38EA9F32-3869-43BA-B215-EB2E5BA62FD5@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is probably getting to be more of a topic for lustre-devel.

There currently isn't any way to do what you ask, since (IIRC) it will cause an error for apps that try to write to the files before the layout is set.

What you could do is to create an LD_PRELOAD library to intercept the open() calls and set O_LOV_DELAY_CREATE and set the layout explicitly for each file. This might be a win if each file needs a different layout, but since it uses two RPCs per file it would be slower than using the default layout.

Cheers, Andreas

On May 18, 2016, at 16:46, John Bauer <bauerj at iodoctors.com<mailto:bauerj@iodoctors.com>> wrote:


Since today's topic seems to be Lustre striping, I will revisit a previous line of questions I had.

Andreas had put me on to O_LOV_DELAY_CREATE which I have been experimenting with. My question is : Is there a way to flag a directory with O_LOV_DELAY_CREATE so that a file created in that directory will be created with O_LOV_DELAY_CREATE also.  Much like a file can inherit a directory's stripe count and stripe size, it would be convenient if a file could also inherit O_LOV_DELAY_CREATE?  That way, for open()s that I can not intercept ( and thus can not set O_LOV_DELAY_CREATE in oflags) , such as those issued by fopen(), I can then get the fd with fileno() and set the striping with ioctl(fd, LL_IOC_LOV_SETSTRIPE, lum).

Thanks

John

--
I/O Doctors, LLC
507-766-0378
bauerj at iodoctors.com<mailto:bauerj@iodoctors.com>

_______________________________________________
lustre-discuss mailing list
lustre-discuss at lists.lustre.org<mailto:lustre-discuss@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-discuss-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160521/de0cd052/attachment.htm>
