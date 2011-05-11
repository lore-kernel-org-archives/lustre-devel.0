From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Wed, 11 May 2011 11:22:59 -0700
Subject: [Lustre-devel] Technical debt in the lustre build system
In-Reply-To: <4DCACFD9.8080902@llnl.gov>
References: <4DC46DDB.4000906@llnl.gov>
	<EBE08B3E-7905-4A4D-9FDB-B27220455FAF@whamcloud.com>
	<4DCACFD9.8080902@llnl.gov>
Message-ID: <4DCAD403.2040802@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 05/11/2011 11:05 AM, Christopher J. Morrone wrote:
> On 05/10/2011 02:53 PM, Andreas Dilger wrote:
 >
>> One issue with separating ldiskfs into it's own package is that fsfilt (or obd-ldiskfs on newer versions of Lustre) are linked closely to the ldiskfs code, and cannot completely be configured using the header file today. That said, it may be practical to store the results of the configure check in the ldiskfs header itself (e.g. #define HAVE_SOME_FEATURE) but this would also need a bit of work.
>>
>> I'd be interested to see how this is handled by the LLNL build system today.
>
> Sure, I'll get Ned to comment on this.

Ned's email got stuck in moderation.  Here's a copy:

"We create a package lustre-ldiskfs-devel that provides all of the 
ldiskfs headers including ldiskfs_extents.h and ldiskfs_jbd2.h.  I 
believe those two along with ldiskfs.h are sufficient to configure 
fsfilt (though the Lustre build system would need to be updated to 
include them instead of their ext4 equivalents).  That said, I like your 
suggestion to have ldiskfs directly export its configuration via ldiskfs.h.

Ned"
